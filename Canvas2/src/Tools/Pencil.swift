//
//  Pencil.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

/** A basic pencil tool, which allows for freehand drawing on the canvas. */
public struct Pencil: Tool {
    
    // MARK: Variables
    
    public var canvas: Canvas?
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas) {
        self.canvas = canvas
    }
    
    
    // MARK: Functions
    
    public func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        let point = firstTouch.metalLocation(in: canvas)
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // Start a new quad when a touch is down.
        canvas.nextQuad = Quad(start: point, brush: canvas.currentBrush.copy())
        canvas.nextQuad?.startForce = canvas.forceEnabled ? canvas.force : 1.0
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        
        // Coalesced touches for apple pencil.
        guard let coalesced = event?.coalescedTouches(for: firstTouch) else { return }
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // NOTE: Run the following code for all of the coalesced touches.
        for cTouch in coalesced {
            let point = cTouch.metalLocation(in: canvas)
            
            // Every time you move, end the current quad and that position.
            guard var next = canvas.nextQuad else { continue }
            next.endForce = canvas.forceEnabled ? canvas.force : 1.0
            
            if let last = canvas.lastQuad {
                next.end(at: point, prevA: last.c, prevB: last.d)
            } else {
                next.end(at: point)
            }
            
            // Add that finalized quad onto the list of quads on the canvas.
            canvas.currentDrawingCurve.append(next)
            
            // Set the last quad so that while you are still drawing, you can
            // use it to get the last quad coordinate points.
            canvas.lastQuad = next
            
            // Start the next quad from the end position, in case the touch is still moving.
            canvas.nextQuad = Quad(start: point, brush: canvas.currentBrush.copy())
        }
    }
    
    public func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        
        // Add the vertices from the currently drawn curve, and remake the buffer.
//        canvas.finishElement()
        canvas.redraw()
        
        // Clear the current drawing curve.
        canvas.nextQuad = nil
        canvas.lastQuad = nil
        canvas.currentDrawingCurve.removeAll()
    }
    
    public func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        
        // Add the vertices from the currently drawn curve, and remake the buffer.
//        canvas.finishElement()
        canvas.redraw()
        
        // Clear the current drawing curve.
        canvas.nextQuad = nil
        canvas.lastQuad = nil
        canvas.currentDrawingCurve.removeAll()
    }
    
}
