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
    
    internal var buffer: MTLBuffer?
    
    internal var brush: Brush
    
    
    
    // MARK: Initialization
    
    init(quads: [Quad], brush: Brush) {
        self.quads = quads
        self.buffer = nil
        self.brush = brush
    }
    
    
    // MARK: Functions
    
    
    
}
