//
//  Canvas.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/7/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

internal let CANVAS_PIXEL_FORMAT: MTLPixelFormat = .bgra8Unorm

/** A Metal-accelerated canvas for drawing and painting. */
public class Canvas: MTKView, MTKViewDelegate {
    
    // MARK: Variables

    // ---> Internal
    
    internal var pipeline: MTLRenderPipelineState!
    internal var commandQueue: MTLCommandQueue!
    internal var textureLoader: MTKTextureLoader!
    internal var sampleState: MTLSamplerState!
    
    internal var viewportVertices: [Vertex]
    internal var mainBuffer: MTLBuffer?
    internal var mainTexture: MTLTexture?
    
    internal var canvasLayers: [Layer]
    internal var currentPath: Element!
    internal var undoRedoManager: UndoRedoManager
    
    internal var force: CGFloat
    internal var registeredTextures: [String : MTLTexture]
    internal var registeredBrushes: [String : Brush]
    
    
    
    // ---> Public
    
    /** The brush that determines the styling of the next curve drawn on the canvas. */
    public var currentBrush: Brush!
    
    /** The tool that is currently used to add objects to the canvas. */
    public var currentTool: Tool! {
        didSet {
            self.canvasDelegate?.didChangeTool(to: self.currentTool)
        }
    }
    
    /** Whether or not the canvas should respond to force as a way to draw curves. */
    public var forceEnabled: Bool
    
    /** The maximum force allowed on the canvas. */
    public var maximumForce: CGFloat {
        didSet {
            self.maximumForce = CGFloat(simd_clamp(Float(self.maximumForce), 0.0, 1.0))
        }
    }
    
    /** Only allow styluses such as the Apple Pencil to be used for drawing. */
    public var stylusOnly: Bool
    
    /** The color to use to clear the canvas, which also serves as the background color. */
    public var canvasColor: UIColor {
        didSet {
            let rgba = self.canvasColor.rgba
            self.clearColor = MTLClearColor(
                red: Double(rgba.red),
                green: Double(rgba.green),
                blue: Double(rgba.blue),
                alpha: Double(rgba.alpha)
            )
        }
    }
    
    /** The index of the current layer. */
    public internal(set) var currentLayer: Int
    
    /** The delegate for the CanvasEvents protocol. */
    public var canvasDelegate: CanvasEvents?
    
    
    
    
    // --> Static/Computed
    
    /** A very basic pencil tool for freehand drawing. */
    lazy internal var pencilTool: Pencil = {
        return Pencil(canvas: self)
    }()
    
    /** A basic tool for creating perfect rectangles. */
    lazy internal var rectangleTool: Rectangle = {
        return Rectangle(canvas: self)
    }()
    
    /** A basic line tool for drawing straight lines. */
    lazy internal var lineTool: Line = {
        return Line(canvas: self)
    }()
    
    /** A basic circle tool for drawing straight lines. */
    lazy internal var ellipseTool: Ellipse = {
        return Ellipse(canvas: self)
    }()
    
    /** A simple eraser. */
    lazy internal var eraserTool: Eraser = {
        return Eraser(canvas: self)
    }()
    
    
    // ---> Overrides
    
    public override var frame: CGRect {
        didSet {
            if device == nil { return }
            
            // Basically, every time you change the view size, clear the canvas using the
            // viewport vertices, which is the a clear color screen.
            mainTexture = makeEmptyTexture(device: self.device, width: frame.width, height: frame.height)
            self.viewportVertices = [
                Vertex(position: CGPoint(x: 0, y: 0), color: canvasColor),
                Vertex(position: CGPoint(x: frame.width, y: 0), color: canvasColor),
                Vertex(position: CGPoint(x: 0, y: frame.height), color: canvasColor),
                Vertex(position: CGPoint(x: frame.width, y: frame.height), color: canvasColor)
            ]
            repaint()
        }
    }
    
    
    
    
    // MARK: Initialization
    
    public init(frame: CGRect = CGRect.zero) {
        self.forceEnabled = true
        self.stylusOnly = false
        self.force = 1.0
        self.maximumForce = 1.0
        self.canvasLayers = []
        self.currentLayer = -1
        self.registeredTextures = [:]
        self.registeredBrushes = [:]
        self.viewportVertices = []
        self.canvasColor = UIColor.clear
        self.undoRedoManager = UndoRedoManager()
        
        // Configure the metal view.
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        self.colorPixelFormat = CANVAS_PIXEL_FORMAT
        self.framebufferOnly = false
        self.clearColor = self.canvasColor.metalClearColor
        self.delegate = self
        self.isOpaque = false
        (self.layer as? CAMetalLayer)?.isOpaque = false
        
        // Configure the pipeline.
        let lib = device?.makeDefaultLibrary()
        let vertProg = lib?.makeFunction(name: "main_vertex")
        let fragProg = lib?.makeFunction(name: "textured_fragment")
        
        self.textureLoader = MTKTextureLoader(device: device!)
        self.commandQueue = device?.makeCommandQueue()
        self.sampleState = buildSampleState(device: device)
        self.pipeline = buildRenderPipeline(device: device, vertProg: vertProg, fragProg: fragProg)
        self.currentBrush = Brush(canvas: self, name: "defaultBrush", size: 10, color: .black) // Default brush
        self.currentTool = self.pencilTool // Default tool
        self.currentPath = Element(quads: [], canvas: self) // Used for drawing temporary paths
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: Functions
    
    // ---> Public
    
    /** Registers a new brush that can be used on this canvas. */
    public func addBrush(_ brush: Brush) {
        var cpy = brush.copy()
        cpy.setupPipeline()
        self.registeredBrushes[brush.name] = cpy
    }
    
    /** Returns the brush with the specified name. */
    public func getBrush(withName name: String) -> Brush? {
        return self.registeredBrushes[name] ?? nil
    }
    
    /** Tells the canvas to keep track of another texture, which can be used later on for different brush strokes. */
    public func addTexture(_ image: UIImage, forName name: String) {
        guard let cg = image.cgImage else { return }
        let texture = try! self.textureLoader.newTexture(cgImage: cg, options: [
            MTKTextureLoader.Option.SRGB : false,
            MTKTextureLoader.Option.allocateMipmaps: false,
            MTKTextureLoader.Option.generateMipmaps: false,
        ])
        self.registeredTextures[name] = texture
    }
    
    /** Returns the texture that has been registered on the canvas using a particular name. */
    public func getTexture(withName name: String) -> MTLTexture? {
        guard let texture = self.registeredTextures[name] else { return nil }
        return texture
    }
    
    /** Tells the canvas to start using a different brush to draw with, based on the registered name. */
    public func changeBrush(to name: String) {
        guard let brush = self.getBrush(withName: name) else { return }
        self.currentBrush = brush
        self.canvasDelegate?.didChangeBrush(to: brush)
    }
    
    /** Allows the user to add custom undo/redo actions to their app. */
    public func addUndoRedo(onUndo: @escaping () -> Any?, onRedo: @escaping () -> Any?) {
        undoRedoManager.add(onUndo: onUndo, onRedo: onRedo)
    }
    
    /** Undoes the last action on  the canvas. */
    public func undo() {
        let _ = undoRedoManager.performUndo()
        rebuildBuffer()
        canvasDelegate?.didUndo(on: self)
    }
    
    /** Redoes the last action on  the canvas. */
    public func redo() {
        let _ = undoRedoManager.performRedo()
        rebuildBuffer()
        canvasDelegate?.didRedo(on: self)
    }
    
    /** Clears the entire canvas. */
    public func clear() {
        var copies = [[Element]]()
        
        for i in 0..<canvasLayers.count {
            copies.append(canvasLayers[i].elements)
            canvasLayers[i].elements.removeAll()
        }
        rebuildBuffer()
        canvasDelegate?.didClear(canvas: self)
        
        // Undo action.
        undoRedoManager.clearRedos()
        undoRedoManager.add(onUndo: { () -> Any? in
            for i in 0..<copies.count {
                self.canvasLayers[i].elements = copies[i]
            }
            self.rebuildBuffer()
            return nil
        }) { () -> Any? in
            for i in 0..<self.canvasLayers.count {
                copies.append(self.canvasLayers[i].elements)
                self.canvasLayers[i].elements.removeAll()
            }
            return nil
        }
    }
    
    /** Clears the drawings on the specified layer. */
    public func clear(layer at: Int) {
        guard at >= 0 && at < canvasLayers.count else { return }
        
        let cpy = canvasLayers[at].elements
        
        canvasLayers[at].elements.removeAll()
        rebuildBuffer()
        canvasDelegate?.didClear(layer: at, on: self)
        
        // Undo action.
        undoRedoManager.clearRedos()
        undoRedoManager.add(onUndo: { () -> Any? in
            self.canvasLayers[at].elements = cpy
            self.rebuildBuffer()
            return nil
        }) { () -> Any? in
            self.canvasLayers[at].elements.removeAll()
            self.rebuildBuffer()
            return nil
        }
    }
    
    /** Exports the canvas as a UIImage. */
    public func export() -> UIImage? {
        guard let drawable = currentDrawable else { return nil }
        guard let cg = drawable.texture.toCGImage2() else { return nil }
        let image = UIImage(cgImage: cg)
        return image
    }
    
    
    
    // ---> Internal
    
    /** Updates the force property of the canvas. */
    internal func setForce(value: CGFloat) {
        if self.forceEnabled == true {
            self.force = min(value, self.maximumForce)
        } else {
            // use simulated force
            var length = CGPoint(x: 1, y: 1).distance(to: .zero)
            length = min(length, 5000)
            length = max(100, length)
            self.force = sqrt(1000 / length)
        }
    }
    
    
    
    // ---> Rendering
    
    /** Ends the curve that is currently being drawn if there is one, then rebuilds the main buffer. */
    internal func rebuildBuffer() {
        // If you were in the process of drawing a curve and are on a valid
        // layer, add that finished element to the layer.
        if var copy = currentPath?.copy() {
            if isOnValidLayer() && copy.quads.count > 0 {
                // Add the newly drawn element to the layer.
                copy.rebuildBuffer()
                canvasLayers[currentLayer].add(element: copy)
                
                // Add an undo action.
                undoRedoManager.clearRedos()
                undoRedoManager.add(onUndo: { () -> Any? in
                    let index = self.canvasLayers[self.currentLayer].elements.count - 1
                    self.canvasLayers[self.currentLayer].remove(at: index)
                    return nil
                }) { () -> Any? in
                    copy.rebuildBuffer()
                    self.canvasLayers[self.currentLayer].add(element: copy)
                    return nil
                }
            }
        }
        
        // Remake the buffer with the newly added element.
        let elements = canvasLayers.filter { $0.isHidden == false }.flatMap { $0.elements }
        let verts = elements.flatMap { $0.quads }.flatMap { $0.vertices }
        let count = verts.count * MemoryLayout<Vertex>.stride
        let defaultViewCount = viewportVertices.count * MemoryLayout<Vertex>.stride
        mainBuffer = device!.makeBuffer(
            bytes: count > 0 ? verts : viewportVertices,
            length: count > 0 ? count : defaultViewCount,
            options: []
        )
    }
    
    /** Finish the current drawing path and add it to the canvas. Then repaint the view. Never needs to be called manually. */
    internal func repaint() {
        // Clear the canvas of whatever was already there.
        mainTexture = makeEmptyTexture(device: device, width: frame.width, height: frame.height)
        
        // Recompute the main buffer.
        guard let drawable = currentDrawable else { return }
        guard let rpd = self.currentRenderPassDescriptor else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else { return }

        // Send the commands to the encoder and redraw the canvas.
        if let buff = mainBuffer {
            let vertCount = buff.length / MemoryLayout<Vertex>.stride
            encoder.setRenderPipelineState(pipeline)
            encoder.setVertexBuffer(buff, offset: 0, index: 0)
            encoder.setFragmentTexture(mainTexture, index: 0)
            encoder.setFragmentSamplerState(sampleState, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertCount)
        }
        
        // Render each layer.
        for i in 0..<canvasLayers.count {
            let layer = canvasLayers[i]
            if layer.isHidden == true { continue }
            canvasLayers[i].render(index: i, buffer: commandBuffer, encoder: encoder)
        }

        // Finishing main encoding and present drawable.
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    /** Updates the drawable on the canvas's underlying MTKView. */
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    public func draw(in view: MTKView) {
        autoreleasepool {
            repaint()
        }
    }
    
} // End of class.
