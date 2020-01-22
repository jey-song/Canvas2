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

/** The global Metal device. */
var dev: MTLDevice!

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
    
    internal var force: CGFloat
    internal var textures: [String : MTLTexture]
    internal var brushes: [String : Brush]
    
    
    // ---> Public
    
    /** The brush that determines the styling of the next curve drawn on the canvas. */
    public internal(set) var currentBrush: Brush!
    
    /** The tool that is currently used to add objects to the canvas. */
    public var currentTool: Tool!
    
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
            self.clearColor = MTLClearColor(red: Double(rgba.red), green: Double(rgba.green), blue: Double(rgba.blue), alpha: Double(rgba.alpha))
        }
    }
    
    /** The index of the current layer. */
    public var currentLayer: Int
    
    
    // --> Static/Computed
    
    /** A very basic pencil tool for freehand drawing. */
    lazy var pencilTool: Pencil = {
        return Pencil(canvas: self)
    }()
    
    /** A basic tool for creating perfect rectangles. */
    lazy var rectangleTool: Rectangle = {
        return Rectangle(canvas: self)
    }()
    
    /** A basic line tool for drawing straight lines. */
    lazy var lineTool: Line = {
        return Line(canvas: self)
    }()
    
    /** A basic circle tool for drawing straight lines. */
    lazy var ellipseTool: Ellipse = {
        return Ellipse(canvas: self)
    }()
    
//    /** A simple eraser. */
//    static let eraserTool: Eraser = {
//        return Eraser()
//    }()
    
    
    // ---> Overrides
    
    public override var bounds: CGRect {
        didSet {
            // Basically, every time you change the view size, clear the canvas using the
            // viewport vertices, which is the a clear color screen.
            mainTexture = makeEmptyTexture(width: bounds.width, height: bounds.height)
            self.viewportVertices = [
                Vertex(position: CGPoint(x: 0, y: 0), color: canvasColor),
                Vertex(position: CGPoint(x: bounds.width, y: 0), color: canvasColor),
                Vertex(position: CGPoint(x: 0, y: bounds.height), color: canvasColor),
                Vertex(position: CGPoint(x: bounds.width, y: bounds.height), color: canvasColor)
            ]
            repaint()
        }
    }
    
    
    
    
    // MARK: Initialization
    
    public init() {
        dev = MTLCreateSystemDefaultDevice()
        self.forceEnabled = true
        self.stylusOnly = false
        self.force = 1.0
        self.maximumForce = 1.0
        self.commandQueue = dev!.makeCommandQueue()
        self.canvasColor = UIColor.white
        self.canvasLayers = []
        self.currentLayer = -1
        self.textures = [:]
        self.brushes = [:]
        self.viewportVertices = []
        
        // Configure the metal view.
        super.init(frame: CGRect.zero, device: dev)
        self.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        self.framebufferOnly = false
        self.clearColor = self.canvasColor.metalClearColor
        self.delegate = self
        
        // Configure the pipeline.
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        
        self.sampleState = buildSampleState()
        self.pipeline = buildRenderPipeline(vertProg: vertProg, fragProg: fragProg)
        self.textureLoader = MTKTextureLoader(device: dev)
        self.currentBrush = Brush(name: "defaultBrush", size: 10, color: .black) // Default brush
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
        self.brushes[brush.name] = cpy
//        self.brushes[brush.name]?.setupPipeline()
    }
    
    /** Returns the brush with the specified name. */
    public func getBrush(withName name: String) -> Brush? {
        return self.brushes[name] ?? nil
    }
    
    /** Tells the canvas to keep track of another texture, which can be used later on for different brush strokes. */
    public func addTexture(_ image: UIImage, forName name: String) {
        guard let cg = image.cgImage else { return }
        let texture = try! self.textureLoader.newTexture(cgImage: cg, options: [
            MTKTextureLoader.Option.SRGB : false,
            MTKTextureLoader.Option.allocateMipmaps: false,
            MTKTextureLoader.Option.generateMipmaps: false,
        ])
        self.textures[name] = texture
    }
    
    /** Returns the texture that has been registered on the canvas using a particular name. */
    public func getTexture(withName name: String) -> MTLTexture? {
        guard let texture = self.textures[name] else { return nil }
        return texture
    }
    
    /** Tells the canvas to start using a different brush to draw with, based on the registered name. */
    public func changeBrush(to name: String) {
        guard let brush = self.getBrush(withName: name) else { return }
        self.currentBrush = brush
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
    
    /** Finish the current drawing path and add it to the canvas. Then repaint the view. */
    internal func repaint() {
        // Get a copy of the current path before we eventually remove it.
        // If you were in the process of drawing something, add it to the
        // current layer.
        if let copy = currentPath?.copy() {
            if isOnValidLayer() {
                canvasLayers[currentLayer].add(element: copy)
            }
        }
        
        // Clear the canvas of whatever was already there.
        mainTexture = makeEmptyTexture(width: bounds.width, height: bounds.height)
        
        // Recompute the main buffer.
        guard let rpd = self.currentRenderPassDescriptor else { print("no descriptor"); return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { print("no command buffer"); return }
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else { print("no encoder"); return }
        guard let drawable = self.currentDrawable else { print("no drawable"); return }
        
        let elements = canvasLayers.flatMap { $0.elements }
        let verts = elements.flatMap { $0.quads }.flatMap { $0.vertices }
        let count = verts.count * MemoryLayout<Vertex>.stride
        let defaultViewCount = viewportVertices.count * MemoryLayout<Vertex>.stride
        mainBuffer = dev.makeBuffer(bytes: count > 0 ? verts : viewportVertices, length: count > 0 ? count : defaultViewCount, options: [])
        
        let vertCount = mainBuffer!.length / MemoryLayout<Vertex>.stride
        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(mainBuffer, offset: 0, index: 0)
        encoder.setFragmentTexture(mainTexture, index: 0)
        encoder.setFragmentSamplerState(sampleState, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertCount)
        
        for var e in elements {
            e.render(buffer: commandBuffer, encoder: encoder)
        }
        
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    /** Updates the drawable on the canvas's underlying MTKView. */
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // redraw
    }
    
    public func draw(in view: MTKView) {
//        guard let rpd = view.currentRenderPassDescriptor else { print("no descriptor"); return }
//        guard let commandBuffer = commandQueue.makeCommandBuffer() else { print("no command buffer"); return }
//        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else { print("no encoder"); return }
//        guard let drawable = view.currentDrawable else { print("no drawable"); return }
        
        
        
//        encoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
    }
}
