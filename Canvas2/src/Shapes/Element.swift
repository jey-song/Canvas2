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
    
    internal var nextQuad: Quad?
    internal var lastQuad: Quad?
    
    internal var canvas: Canvas
    
    
    
    // MARK: Initialization
    
    init(quads: [Quad], canvas: Canvas) {
        self.quads = quads
        self.canvas = canvas
        
        if quads.count > 0 {
            self.nextQuad = quads[0]
        }
    }
    
    public func copy() -> Element {
        let e = Element(quads: self.quads, canvas: self.canvas)
        return e
    }
    
    
    
    // MARK: Functions
    
    /** Ends the last quad that exists on this element. */
    internal mutating func endLastQuad(at point: CGPoint) {
        guard var next = nextQuad else { return }
        next.endForce = canvas.forceEnabled ? canvas.force : 1.0
        
        // Call the quad's end method to set the vertices.
        if let last = lastQuad {
            next.end(at: point, prevA: last.c, prevB: last.d)
        } else {
            next.end(at: point)
        }
        
        // Finally, add the next quad onto this element.
        quads.append(next)
        
        // Make sure to move the pointers.
        lastQuad = next
        nextQuad = Quad(start: point, brush: canvas.currentBrush.copy())
    }

    /** Finishes this element so that no more quads can be added to it without starting an
     entirely new element (i.e. lifting the stylus and drawing a new curve). */
    internal mutating func closePath() {
        nextQuad = nil
        lastQuad = nil
        quads = []
    }
    
    /** Renders the element to the screen. */
    internal func render() {
        guard quads.count > 0 else { return }
        guard let rpd = canvas.currentRenderPassDescriptor else { return }
        guard let buffer = canvas.commandQueue.makeCommandBuffer() else { return }
        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: rpd) else { return }
        
        for quad in quads {
            let brush = quad.brush
//            let vertices = quad.vertices
            let vBuffer = quad.buffer
//            guard vertices.count > 0 else {
//                print("No vertices in this quad")
//                continue
//            }
//            guard let vBuffer = dev.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: []) else {
////                encoder.endEncoding()
//                return
//            }
            
            encoder.setRenderPipelineState(brush.pipeline)
            encoder.setVertexBuffer(vBuffer, offset: 0, index: 0)
            if let txr = brush.texture {
                encoder.setFragmentTexture(txr, index: 0)
            }
            if let vBuffer = vBuffer {
                let count = vBuffer.length / MemoryLayout<Vertex>.stride
                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
            }
        }
        encoder.endEncoding()
        print("Encoded single element")
    }
    
    
}
