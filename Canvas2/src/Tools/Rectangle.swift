//
//  Rectangle.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A tool that draws a rectangle from the initial touch point outward to the end touch point. */
public struct Rectangle: Tool {
    
    // MARK: Variables
    
    public var canvas: Canvas?
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas) {
        self.canvas = canvas
    }
    
    
    // MARK: Functions
    
    public func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        let point = firstTouch.metalLocation(in: canvas)
        guard canvas.isOnValidLayer() else { return false }
        
        // When drawing a rectangle, you only need one quad to work with.
        let quad = Quad(start: point)
        canvas.currentPath.startPath(quad: quad)
        return true
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.currentPath != nil else { print("No current path"); return false }
        guard canvas.isOnValidLayer() else { return false }
        
        let point = firstTouch.metalLocation(in: canvas)
        canvas.currentPath.endRectangle(at: point)
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
