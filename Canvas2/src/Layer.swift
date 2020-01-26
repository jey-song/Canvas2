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
public class Layer {
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Functions
    
    /** Makes sure that this layer understands that a new element was added on it. */
    internal func add(element: Element) {
        self.elements.append(element)
    }
    
    internal func render(index: Int, buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        for var element in elements {
            element.render(buffer: buffer, encoder: encoder)
        }
        
        // Whatever is current being drawn on the screen, display it immediately.
        if canvas.currentLayer == index {
            if var cp = canvas.currentPath {
                if cp.quads.count > 0 && canvas.canvasLayers[canvas.currentLayer].isLocked == false {
                    cp.rebuildBuffer()
                    cp.render(buffer: buffer, encoder: encoder)
                }
            }
        }
    }
    
}
