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
    
    public var name: String
    
    public var canvas: Canvas?
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas) {
        self.canvas = canvas
        self.name = "pencil"
    }
    
    
    // MARK: Functions
    
    public func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        let point = firstTouch.metalLocation(in: canvas)
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // Start a new quad when a touch is down.
        var quad = Quad(start: point)
        quad.startForce = canvas.forceEnabled ? canvas.force : 1.0
        
        canvas.currentPath.startPath(quad: quad)
        return true
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.currentPath != nil else { print("No current path"); return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // Coalesced touches for apple pencil.
        guard let coalesced = event?.coalescedTouches(for: firstTouch) else { return false }
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // NOTE: Run the following code for all of the coalesced touches.
        for cTouch in coalesced {
            let point = cTouch.metalLocation(in: canvas)
            canvas.currentPath!.endPencil(at: point)
        }
        return true
    }
    
    public func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    public func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
}
