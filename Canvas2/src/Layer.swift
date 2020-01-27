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
    
    /** Removes an element from this layer. */
    internal func remove(at: Int) {
        guard at >= 0 && at < elements.count else { return }
        elements.remove(at: at)
    }
    
    /** Erases points from this layer by making them transparent. */
    internal func eraseVertices(point: CGPoint) {
        let size = (((canvas.currentBrush.size / 100) * 4) / 2) / 50
        let opacity = canvas.currentBrush!.opacity * canvas.force
        
        // Go through each element...
        for i in 0..<elements.count {
            let element = elements[i]
            
            // Then through each quad...
            for j in 0..<element.quads.count {
                let quad = element.quads[j]
                
                // Then through the vertices.
                for k in 0..<quad.vertices.count {
                    let vert = quad.vertices[k]
                    
                    // Tell the vertex to add on to its erase variable.
                    if CGPoint.inRange(
                        x: vert.position.x,
                        y: vert.position.y,
                        a: Float(point.x),
                        b: Float(point.y),
                        size: Float(size))
                    {
                        elements[i].quads[j].vertices[k].erase += Float(opacity)
                    }
                }
            }
        }
    }
    
    
    // MARK: Rendering
    
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
