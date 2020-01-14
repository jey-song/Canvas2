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
    
    // INTERNAL
    internal var pipeline: MTLRenderPipelineState!
    internal var commands: MTLCommandQueue!
    
    internal var curves: [Curve]
    internal var nextCurve: [Line]
    
    internal var currentBrush: Brush
    
    
    public init() {
        dev = MTLCreateSystemDefaultDevice()
        self.curves = []
        self.nextCurve = []
        self.currentBrush = Brush(size: 10, color: .black)
        self.commands = dev!.makeCommandQueue()
        super.init(frame: CGRect.zero, device: dev)
        
        // Configure the metal view.
        self.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        self.framebufferOnly = true
        
        // Configure the pipeline.
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "colored_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "colored_fragment") else { return }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertProg
        descriptor.fragmentFunction = fragProg
        descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
        
        pipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    
    /** Updates the drawable on the canvas's underlying MTKView. */
    public override func draw() {
        autoreleasepool {
            guard let lay: CAMetalLayer = self.layer as? CAMetalLayer else { return }
            guard let drawable = lay.nextDrawable() else { return }
            
            // Create a descriptor for the pipeline.
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].texture = drawable.texture // TODO: This is where you can change the texture.
            descriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
            descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
            
            // Create a pixel buffer for the command queue. Also make an encoder for
            // the pipeline.
            guard let buffer = self.commands.makeCommandBuffer() else { return }
            guard let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
            encoder.setRenderPipelineState(self.pipeline)
            
            // Make sure to draw the temporary curve while drawing.
            if nextCurve.count > 0 {
                var whileDrawing: Curve = Curve()
                whileDrawing.add(lines: nextCurve)
                whileDrawing.render(encoder: encoder)
            }
            
            // Draw tiny little lines between each set of points in the curves array.
            // The Curve struct should handle this on its own, so basically just draw
            // each curve.
            for curve in self.curves {
                curve.render(encoder: encoder)
            }
            
            // End the encoding and present the new drawable after its been updated.
            encoder.endEncoding()
            buffer.present(drawable)
            buffer.commit()
        }
    }
    
}
