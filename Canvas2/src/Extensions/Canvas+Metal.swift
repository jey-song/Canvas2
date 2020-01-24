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

/** Builds a render pipeline. */
internal func buildRenderPipeline(
    vertProg: MTLFunction,
    fragProg: MTLFunction,
    eraserSettingsOn: Bool = false
) -> MTLRenderPipelineState {
    // Make a descriptor for the pipeline.
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.vertexFunction = vertProg
    descriptor.fragmentFunction = fragProg
    descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    descriptor.colorAttachments[0].isBlendingEnabled = true
    descriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.add
    descriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.add
    descriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
    descriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.one
    descriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
    descriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
    if eraserSettingsOn == true {
        descriptor.colorAttachments[0].alphaBlendOperation = .reverseSubtract
        descriptor.colorAttachments[0].rgbBlendOperation = .reverseSubtract
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceColor
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .zero
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .zero
    }
    
    
    
//    attachment.isBlendingEnabled = true
//    attachment.alphaBlendOperation = .reverseSubtract
//    attachment.rgbBlendOperation = .reverseSubtract
//    attachment.sourceRGBBlendFactor = .zero
//    attachment.sourceAlphaBlendFactor = .one
//    attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
//    attachment.destinationAlphaBlendFactor = .one
    
    let state = try! dev.makeRenderPipelineState(descriptor: descriptor)
    return state
}


/** Builds a sample descriptor for the fragment function. */
internal func buildSampleState() -> MTLSamplerState? {
    let sd = MTLSamplerDescriptor()
    sd.magFilter = .linear
    sd.minFilter = .nearest
    sd.mipFilter = .linear
    sd.rAddressMode = .mirrorRepeat
    sd.sAddressMode = .mirrorRepeat
    sd.tAddressMode = .mirrorRepeat
    guard let sampleState = dev.makeSamplerState(descriptor: sd) else {
        return nil
    }
    return sampleState
}


/** Creates an empty texture. */
internal func makeEmptyTexture(width: CGFloat, height: CGFloat, format: MTLPixelFormat = .bgra8Unorm) -> MTLTexture? {
    guard width * height > 0 else { return nil }
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: format,
        width: Int(width),
        height: Int(height),
        mipmapped: false
    )
    textureDescriptor.usage = [.renderTarget, .shaderRead]
    return dev!.makeTexture(descriptor: textureDescriptor)
}
