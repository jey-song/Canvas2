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
    
    internal var isLocked: Bool
    
    internal var isHidden: Bool
    
    
    
    
    // MARK: Initialization
    
    init(canvas: Canvas) {
        self.canvas = canvas
        self.elements = []
        self.isLocked = false
        self.isHidden = false
    }
    
    
    // MARK: Functions
    
    /** Makes sure that this layer understands that a new element was added on it. */
    internal mutating func add(element: Element) {
        self.elements.append(element)
    }
    
    
    /** Renders the elements on this layer. */
    internal mutating func render(index: Int, buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        for var element in elements {
            element.render(buffer: buffer, encoder: encoder)
        }
        
        // Draw the current path.
        if index == canvas.currentLayer {
            if var cp = canvas.currentPath {
                if cp.quads.count > 0 && isLocked == false {
                    cp.render(buffer: buffer, encoder: encoder)
                }
            }
        }
    }
    
}
