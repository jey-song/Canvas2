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
public struct Layer: Codable {
    
    // MARK: Variables
    
    internal var canvas: Canvas?
    
    internal var elements: [Element]
    
    internal var isLocked: Bool
    
    internal var isHidden: Bool
    
    
    
    
    
    // MARK: Initialization
    
    init(canvas: Canvas?) {
        self.canvas = canvas
        self.elements = []
        self.isLocked = false
        self.isHidden = false
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: LayerCodingKeys.self)
        
        self.elements = try container?.decodeIfPresent([Element].self, forKey: .elements) ?? []
        self.isLocked = try container?.decodeIfPresent(Bool.self, forKey: .isLocked) ?? false
        self.isHidden = try container?.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
    }
    
    
    
    // MARK: Functions
    
    /** Makes sure that this layer understands that a new element was added on it. */
    internal mutating func add(element: Element) {
        self.elements.append(element)
    }
    
    /** Removes an element from this layer. */
    internal mutating func remove(at: Int) {
        guard at >= 0 && at < elements.count else { return }
        elements.remove(at: at)
    }
    
    /** Erases points from this layer by making them transparent. */
    internal mutating func eraseVertices(point: CGPoint) {
//        guard let canvas = self.canvas else { return }
//        let size = (((canvas.currentBrush.size / 100) * 4) / 2) / 50
//        let opacity = canvas.currentBrush!.opacity * canvas.force
//
//        // Go through each element...
//        for i in 0..<elements.count {
//            let element = elements[i]
//
//            // Then through each quad...
//            for j in 0..<element.verts.count {
//                let quad = element.quads[j]
//
//                // Then through the vertices.
//                for k in 0..<quad.vertices.count {
//                    let vert = quad.vertices[k]
//
//                    // Tell the vertex to add on to its erase variable.
//                    if CGPoint.inRange(
//                        x: vert.position.x,
//                        y: vert.position.y,
//                        a: Float(point.x),
//                        b: Float(point.y),
//                        size: Float(size))
//                    {
//                        elements[i].quads[j].vertices[k].erase += Float(opacity)
//                    }
//                }
//            }
//        }
    }
    
    
    // MARK: Rendering
    
    internal mutating func render(index: Int, buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        guard let canvas = self.canvas else { return }
        
        for var element in elements {
            
            // Occurs when loading from data.
            if element.canvas == nil {
                element.canvas = canvas
                element.rebuildBuffer()
            }
            
            element.render(canvas: canvas, buffer: buffer, encoder: encoder)
        }
        
        // Whatever is current being drawn on the screen, display it immediately.
        if canvas.currentLayer == index {
            if var cp = canvas.currentPath {
                if cp.verts.count > 0 && isLocked == false {
                    cp.rebuildBuffer()
                    cp.render(canvas: canvas, buffer: buffer, encoder: encoder)
                }
            }
        }
    }
    
    
    // MARK: Decoding
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LayerCodingKeys.self)
        
        try container.encode(elements, forKey: .elements)
        try container.encode(isLocked, forKey: .isLocked)
        try container.encode(isHidden, forKey: .isHidden)
    }
    
}
