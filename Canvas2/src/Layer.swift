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
    
    internal var canvas: Canvas
    
    internal var elements: [Element]
    
    
    
    
    // MARK: Initialization
    
    init(canvas: Canvas) {
        self.canvas = canvas
        self.elements = []
    }
    
    
    // MARK: Functions
    
    /** Makes sure that this layer understands that a new element was added on it. */
    internal mutating func add(element: Element) {
        self.elements.append(element)
    }
    
    
}
