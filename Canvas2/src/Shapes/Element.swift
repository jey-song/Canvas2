//
//  Element.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/19/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** An element is a manager for a group of quads on a layer of the canvas. */
public struct Element {
    
    // MARK: Variables
    
    internal var quads: [Quad]
    
    internal var pipeline: MTLRenderPipelineState!
    
    
    
    // MARK: Initialization
    
    init(quads: [Quad]) {
        self.quads = quads
        
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        self.pipeline = buildRenderPipeline(vertProg: vertProg, fragProg: fragProg)
    }
    
    
    
    // MARK: Functions
    
    internal func render(canvas: Canvas) {
        
    }
    
    
}
