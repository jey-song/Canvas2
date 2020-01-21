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
    
    public var canvas: Canvas?
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas) {
        self.canvas = canvas
    }
    
    
    // MARK: Functions
    
    public func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        let point = firstTouch.metalLocation(in: canvas)
        
        
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        let point = firstTouch.metalLocation(in: canvas)
        
        
    }
    
    public func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        
        // Add the vertices from the currently drawn curve, and remake the buffer.
        canvas.finishElement()
        
        // Clear the current drawing curve.
        canvas.nextQuad = nil
        canvas.lastQuad = nil
        canvas.currentDrawingCurve.removeAll()
    }
    
    public func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        
        // Add the vertices from the currently drawn curve, and remake the buffer.
        canvas.finishElement()
        
        // Clear the current drawing curve.
        canvas.nextQuad = nil
        canvas.lastQuad = nil
        canvas.currentDrawingCurve.removeAll()
    }
    
}
