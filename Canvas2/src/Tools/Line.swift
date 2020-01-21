//
//  Line.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A tool that draws a straight line from the initial touch point to the end touch point. */
public struct Line: Tool {
    
    // MARK: Variables
    
    public var canvas: Canvas?
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas) {
        self.canvas = canvas
    }
    
    
    // MARK: Functions
    
    public func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let canvas = self.canvas else { return }
//        let point = firstTouch.metalLocation(in: canvas)
//
//        // When drawing a line, you only need one quad to work with.
//        canvas.nextQuad = Quad(start: point, brush: canvas.currentBrush.copy())
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let canvas = self.canvas else { return }
//        guard var next = canvas.nextQuad else { return }
//
//        let point = firstTouch.metalLocation(in: canvas)
//        next.end(at: point)
//
//        // End and display the quad as a line where you currently drag.
//        next.endAsLine(at: point)
//        canvas.currentPath?.quads = [next]
    }
    
    public func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let canvas = self.canvas else { return }
//
//        // Add the vertices from the currently drawn curve, and remake the buffer.
//        canvas.finishElement()
//
//        // Clear the current drawing curve.
//        canvas.nextQuad = nil
//        canvas.lastQuad = nil
//        canvas.currentPath = nil
    }
    
    public func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let canvas = self.canvas else { return }
//        
//        // Add the vertices from the currently drawn curve, and remake the buffer.
//        canvas.finishElement()
//        
//        // Clear the current drawing curve.
//        canvas.nextQuad = nil
//        canvas.lastQuad = nil
//        canvas.currentPath = nil
    }
    
}
