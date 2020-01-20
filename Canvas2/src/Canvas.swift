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
public class Canvas: MTKView {
    
    // MARK: Variables

    // ---> Internal
    
    internal var pipeline: MTLRenderPipelineState!
    internal var commands: MTLCommandQueue!
    internal var samplerState: MTLSamplerState!
    
    internal var canvasLayers: [Layer]
    internal var mainBuffer: MTLBuffer?
        
    internal var currentDrawingCurve: [Quad]
    internal var nextQuad: Quad?
    internal var lastQuad: Quad?
    
    internal var force: CGFloat
    internal var textures: [String:MTLTexture]
    
    
    // ---> Public
    
    /** The brush that determines the styling of the next curve drawn on the canvas. */
    public var currentBrush: Brush
    
    /** The tool that is currently used to add objects to the canvas. */
    public var currentTool: Tool {
        didSet {
            // Make sure to reset the canvas reference for each tool.
            self.currentTool.canvas = self
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
    public var canvasColor: UIColor
    
    /** The index of the current layer. */
    public var currentLayer: Int
    
    
    // --> Static/Computed
    
    /** A very basic pencil tool for freehand drawing. */
    static let pencilTool: Pencil = {
        return Pencil()
    }()
    
    /** A basic tool for creating perfect rectangles. */
    static let rectangleTool: Rectangle = {
        return Rectangle()
    }()
    
    /** A basic line tool for drawing straight lines. */
    static let lineTool: Line = {
        return Line()
    }()
    
    /** A basic circle tool for drawing straight lines. */
    static let ellipseTool: Ellipse = {
        return Ellipse()
    }()
    
//    /** A simple eraser. */
//    static let eraserTool: Eraser = {
//        return Eraser()
//    }()
    
    
    
    
    // MARK: Initialization
    
    public init() {
        dev = MTLCreateSystemDefaultDevice()
        self.forceEnabled = true
        self.stylusOnly = false
        self.force = 1.0
        self.maximumForce = 1.0
        self.currentBrush = Brush(size: 10, color: .black)
        self.currentTool = Canvas.pencilTool
        self.commands = dev!.makeCommandQueue()
        self.currentDrawingCurve = []
        self.canvasColor = UIColor.white
        self.canvasLayers = []
        self.currentLayer = -1
        self.textures = [:]
        
        // Configure the metal view.
        super.init(frame: CGRect.zero, device: dev)
        self.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        self.framebufferOnly = false
                
        // Configure the pipeline.
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        
        let sampleDescriptor = MTLSamplerDescriptor()
        sampleDescriptor.minFilter = MTLSamplerMinMagFilter.linear
        sampleDescriptor.magFilter = MTLSamplerMinMagFilter.linear
        sampleDescriptor.sAddressMode = MTLSamplerAddressMode.mirrorRepeat
        sampleDescriptor.tAddressMode = MTLSamplerAddressMode.mirrorRepeat
                
        self.samplerState = device.makeSamplerState(descriptor: sampleDescriptor)
        self.pipeline = self.buildRenderPipeline(vertProg: vertProg, fragProg: fragProg)
        self.currentTool.canvas = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: Functions
    
    /** Tells the canvas to keep track of another texture, which can be used later on for different brush strokes. */
    public func addTexture(from image: UIImage, forID id: String) {
        guard let cg = image.cgImage else { return }

        let loader = MTKTextureLoader(device: dev)
        let texture = try! loader.newTexture(cgImage: cg, options: [
            MTKTextureLoader.Option.SRGB : true,
            MTKTextureLoader.Option.allocateMipmaps: true,
            MTKTextureLoader.Option.generateMipmaps: true
        ])
        self.textures[id] = texture
    }
    
    
    /** Returns the texture that has been registered on the canvas using a particular ID. */
    public func getTexture(fromID id: String) -> MTLTexture? {
        guard let texture = self.textures[id] else { return nil }
        return texture
    }
    
    
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
    

    /** Re-computes the vertex buffer after new points are added. */
    internal func finalizeCurveAndRemakeBuffer() {
        // Make sure there is always at least one layer.
        guard self.canvasLayers.count > 0 else { return }
        guard self.currentLayer >= 0 && self.currentLayer < self.canvasLayers.count else { return }
        
        // Add the element to the main array. Then tell the current layer that the element
        // that was just added was technically added onto that layer.
        let element: Element = Element(quads: currentDrawingCurve, brush: currentBrush.copy())
        self.canvasLayers[self.currentLayer].add(element: element)
        
        // Rebuild the buffer.
        let allElements = self.canvasLayers.flatMap { lay -> [Element] in
            return lay.elements
        }
        let allVertices = allElements.flatMap { ele -> [Vertex] in
            return ele.quads.flatMap { q -> [Vertex] in return q.vertices }
        }
        let totalLength = allVertices.count * MemoryLayout<Vertex>.stride
        guard totalLength > 0 else { return }
        self.mainBuffer = dev.makeBuffer(bytes: allVertices, length: totalLength, options: [])
    }
    
    
    /** Updates the drawable on the canvas's underlying MTKView. */
    public override func draw() {
        autoreleasepool {
            guard let lay: CAMetalLayer = self.layer as? CAMetalLayer else { return }
            guard let drawable = lay.nextDrawable() else { return }
            let rgba = self.canvasColor.rgba
            
            // Create a descriptor for the pipeline.
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].texture = drawable.texture
            descriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
            descriptor.colorAttachments[0].storeAction = MTLStoreAction.store
            descriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: Double(rgba.red), green: Double(rgba.green), blue: Double(rgba.blue), alpha: Double(rgba.alpha)
            )
            
            // Create a pixel buffer for the command queue. Also make an encoder for
            // the pipeline.
            guard let buffer = self.commands.makeCommandBuffer() else { return }
            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
            encoder.setRenderPipelineState(self.pipeline)
            
            // Set the texture if the current brush has one.
            self.textures.enumerated().forEach { (offset: Int, element: (key: String, value: MTLTexture)) in
                encoder.setFragmentTexture(element.value, index: offset)
            }
            encoder.setFragmentSamplerState(self.samplerState, index: 0)

            // Once we have the buffer, draw it in one step rather than keeping
            // track of each curve on every render pass.
            if let b = self.mainBuffer {
                let vertCount = b.length / MemoryLayout<Vertex>.stride
                encoder.setVertexBuffer(b, offset: 0, index: 0)
                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertCount)
            }
            
            // Render the shape that is currently being drawn. This is just so
            // that you don't have to wait until the line is finished before
            // it shows up on the screen.
            /// TODO: Later on, instead of drawing the current curve as a separte render call, just insert it at
            /// the correct location in relation to the current layer in the total vertices array. Then, once it has
            /// been drawn, remove that subrange from the total vertices array.
            if self.canvasLayers.count > 0 {
                for quad in currentDrawingCurve {
                    quad.render(encoder: encoder)
                }
            }
            
            // End the encoding and present the new drawable after its been updated.
            encoder.endEncoding()
            buffer.present(drawable)
            buffer.commit()
            
        }
    }
    
}
