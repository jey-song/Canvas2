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
    
    // --> Internal
    
    internal var brush: Brush
    internal var quads: [Quad]
    
    internal var nextQuad: Quad?
    internal var lastQuad: Quad?
    
    internal var canvas: Canvas
    internal var buffer: MTLBuffer?
    
    
    // --> Public
    
    /** Returns the number of quad segments that make up this element. */
    public var length: Int {
        return quads.count
    }
    
    
    
    // MARK: Initialization
    
    init(quads: [Quad], canvas: Canvas, brush: Brush? = nil) {
        self.quads = quads
        self.canvas = canvas
        self.brush = brush ?? canvas.currentBrush
        
        if quads.count > 0 {
            self.nextQuad = quads[0]
        }
    }
    
    public func copy() -> Element {
        let e = Element(quads: self.quads, canvas: self.canvas, brush: self.brush)
        return e
    }
    
    
    
    // MARK: Functions
    
    /** Starts a new path using this element. */
    internal mutating func startPath(quad: Quad) {
        self.brush = canvas.currentBrush
        self.quads = [quad]
        self.nextQuad = self.quads[0]
    }
    
    /** Finishes this element so that no more quads can be added to it without starting an
     entirely new element (i.e. lifting the stylus and drawing a new curve). */
    internal mutating func closePath() {
        nextQuad = nil
        lastQuad = nil
        quads = []
    }
    
    /** Ends the last quad that exists on this element. */
    internal mutating func endPencil(at point: CGPoint) {
        guard var next = nextQuad else { return }
        next.endForce = canvas.forceEnabled ? canvas.force : 1.0
        
        // Call the quad's end method to set the vertices.
        if let last = lastQuad { next.end(at: point, brush: self.brush, prevA: last.c, prevB: last.d) }
        else { next.end(at: point, brush: self.brush) }
        
        // Finally, add the next quad onto this element.
        quads.append(next)
        
        // Make sure to move the pointers.
        lastQuad = next
        nextQuad = Quad(start: point)
    }
    
    /**Ends the curve as a rectangle.  */
    internal mutating func endRectangle(at point: CGPoint) {
        guard var next = nextQuad else { return }

        // End and display the quad as a rectangle where you currently drag.
        next.endAsRectangle(at: point, brush: self.brush)
        quads = [next]
    }
    
    /** Ends the curve as a line. */
    internal mutating func endLine(at point: CGPoint) {
        guard var next = nextQuad else { return }
        
        // End and display the quad as a line where you currently drag.
        next.endAsLine(at: point, brush: self.brush)
        quads = [next]
    }
    
    /** Ends the curve as an ellipse. */
    internal mutating func endEllipse(at point: CGPoint) {
        guard var next = nextQuad else { return }
        
        // End and display the quad as an ellipse where you currently drag.
        next.endAsCircle(at: point, brush: self.brush)
        quads = [next]
    }
    
    
    
    // MARK: Rendering
    
    /** Rebuilds the buffer. */
    internal mutating func rebuildBuffer() {
        let vertices = quads.flatMap { $0.vertices }
        guard vertices.count > 0 else { return }
        buffer = dev.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
    }
    
    /** Renders the element to the screen. */
    internal mutating func render(buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        guard quads.count > 0 else { return }
        
        // Make a new buffer out of all of the vertices on this element.
        guard let vBuffer = self.buffer else { return }
        
        // Set the properties on the encoder for this element and the brush it uses specifically.
        encoder.setRenderPipelineState(brush.pipeline)
        encoder.setVertexBuffer(vBuffer, offset: 0, index: 0)
        
        if let txr = brush.texture { encoder.setFragmentTexture(txr, index: 0) }
        encoder.setFragmentSamplerState(canvas.sampleState, index: 0)
        
        let count = vBuffer.length / MemoryLayout<Vertex>.stride
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
    }
    
    
}
