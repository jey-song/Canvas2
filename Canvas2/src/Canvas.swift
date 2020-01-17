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
    internal var quadsBuffer: MTLBuffer?
    internal var totalVertices: [Vertex]
    
    internal var currentDrawingCurve: [Quad]
    internal var nextQuad: Quad?
    internal var lastQuad: Quad?
    
    internal var force: CGFloat
    
    
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
        self.totalVertices = []
        
        // Configure the metal view.
        super.init(frame: CGRect.zero, device: dev)
        self.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        self.framebufferOnly = true
        
        // Configure the pipeline.
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "main_fragment") else { return }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertProg
        descriptor.fragmentFunction = fragProg
        descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.add
        descriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.one
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        
        self.pipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
        self.currentTool.canvas = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: Functions
    
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
        for quad in self.currentDrawingCurve {
            self.totalVertices.append(contentsOf: quad.vertices)
        }
        let len = totalVertices.count * MemoryLayout<Vertex>.stride
        guard len > 0 else { return }
        
        quadsBuffer = dev.makeBuffer(
            bytes: self.totalVertices,
            length: len,
            options: []
        )
    }
    
    /** Updates the drawable on the canvas's underlying MTKView. */
    public override func draw() {
        autoreleasepool {
            guard let lay: CAMetalLayer = self.layer as? CAMetalLayer else { return }
            guard let drawable = lay.nextDrawable() else { return }
            
            // Create a descriptor for the pipeline.
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].texture = drawable.texture
            descriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
            descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
            
            // Create a pixel buffer for the command queue. Also make an encoder for
            // the pipeline.
            guard let buffer = self.commands.makeCommandBuffer() else { return }
            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
            encoder.setRenderPipelineState(self.pipeline)
            
            // Once we have the buffer, draw it in one step rather than keeping
            // track of each curve on every render pass.
            if let b = self.quadsBuffer {
                let vertCount = b.length / MemoryLayout<Vertex>.stride
                encoder.setVertexBuffer(b, offset: 0, index: 0)
                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertCount)
            }
            
            // Render the shape that is currently being drawn. This is just so
            // that you don't have to wait until the line is finished before
            // it shows up on the screen.
            for quad in currentDrawingCurve {
                quad.render(encoder: encoder)
            }
            
            // End the encoding and present the new drawable after its been updated.
            encoder.endEncoding()
            buffer.present(drawable)
            buffer.commit()
        }
    }
    
}
