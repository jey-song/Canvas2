//
//  Canvas+Metal.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

extension Canvas {
    
    /** Builds a render pipeline. */
    internal func buildRenderPipeline(vertProg: MTLFunction, fragProg: MTLFunction) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertProg
        descriptor.fragmentFunction = fragProg
        descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.add
        descriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.one
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        
        let state = try! dev.makeRenderPipelineState(descriptor: descriptor)
        return state
    }
    
    
    
    
    
    
}
