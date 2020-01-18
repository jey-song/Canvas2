//
//  Layer.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** A layer on the canvas. */
public struct Layer {
    
    // MARK: Variables
    
    internal var buffer: MTLBuffer?
    
    internal var vertices: [Vertex]    
    
    
    // MARK: Initialization
    
    init() {
        self.vertices = []
    }
    
}
