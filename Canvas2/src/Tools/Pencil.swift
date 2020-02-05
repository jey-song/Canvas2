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
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: ToolCodingKeys.self)
        name = try container?.decodeIfPresent(String.self, forKey: .name) ?? "pencil"
    }
    
    
    
    // MARK: Functions
    
    public func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        let point = firstTouch.metalLocation(in: canvas)
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // Start a new quad when a touch is down.
//        let quad = Quad(start: point)
        let v = Vertex(
            position: point,
            size: 0,
            color: canvas.currentBrush.color.withAlphaComponent(canvas.currentBrush.opacity),
            texture: canvas.currentBrush.textureName != nil ? SIMD2<Float>(x: 0, y: 0) : nil
        )
        canvas.currentPath.startPath(vert: v)
        canvas.bezier.begin(with: point)
        return true
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.currentPath != nil else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // All important touches for apple pencil.
        guard let coalesced = event?.coalescedTouches(for: firstTouch) else { return false }
        guard let pred = event?.predictedTouches(for: firstTouch) else { return false }
        
        // Get the force from the user input.
        canvas.setForce(value: firstTouch.force)
        
        // NOTE: Run the following code for all of the touches.
        var total = coalesced
        total.append(contentsOf: pred)
        for touch in total {
            let point = touch.metalLocation(in: canvas)
            canvas.currentPath!.endPencil(at: point)
        }
        return true
    }
    
    public func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        
        if let first = touches.first {
            let p = first.metalLocation(in: canvas)
            canvas.currentPath!.endPencil(at: p)
        }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    public func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        
        if let first = touches.first {
            let p = first.metalLocation(in: canvas)
            canvas.currentPath!.endPencil(at: p)
        }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    
    // MARK: Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToolCodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
}
