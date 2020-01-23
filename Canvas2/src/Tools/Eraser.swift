//
//  Eraser.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/17/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A tool for erasing pixels from the canvas. */
public struct Eraser: Tool {
    
    // MARK: Variables
    
    public var name: String
    
    public var canvas: Canvas?
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas) {
        self.canvas = canvas
        self.name = "eraser"
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
    
    func inRange(x: Float, y: Float, a: Float, b: Float, size: Float) -> Bool {
        return (x >= a - size && x <= a + size) && (y >= b - size && y <= b + size)
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.currentPath != nil else { print("No current path"); return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // Coalesced touches for apple pencil.
        guard let coalesced = event?.coalescedTouches(for: firstTouch) else { return false }
        guard let t = coalesced.first else { return false }
        let point = t.metalLocation(in: canvas)
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // NOTE: Run the following code for all of the coalesced touches.
        let size: Float = Float((((canvas.currentBrush.size / 100) * 4) / 2) / 50)
        
        let verts = canvas.canvasLayers[canvas.currentLayer].elements.flatMap { $0.quads }.flatMap { $0.vertices }
        for i in 0..<canvas.canvasLayers[canvas.currentLayer].elements.count {
            let element = canvas.canvasLayers[canvas.currentLayer].elements[i]
            for j in 0..<element.quads.count {
                let quad = element.quads[j]
                for k in 0..<quad.vertices.count {
                    let vert = quad.vertices[k]
                    if self.inRange(x: vert.position.x, y: vert.position.y, a: Float(point.x), b: Float(point.y), size: Float(size)) {
                        canvas.canvasLayers[canvas.currentLayer].elements[i].quads[j].vertices[k].erased = true
                    }
                }
            }
        }
        canvas.rebuildBuffer()
        
//        for cTouch in coalesced {
//            let point = cTouch.metalLocation(in: canvas)
//            canvas.currentPath!.endPencil(at: point)
//        }
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
