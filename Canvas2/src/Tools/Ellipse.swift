//
//  Ellipse.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A tool that draws an ellipse starting from the center start point to the end width (distance). */
public struct Ellipse: Tool {
    
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

        // When drawing an ellipse, you only need one quad to work with.
//        canvas.nextQuad = Quad(start: point, brush: canvas.currentBrush.copy())
//        canvas.currentPath = Element(quads: [canvas.nextQuad!], canvas: canvas)
        let quad = Quad(start: point)
        canvas.currentPath.startPath(quad: quad)
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        guard canvas.currentPath != nil else { print("No current path"); return }
        
        let point = firstTouch.metalLocation(in: canvas)
        canvas.currentPath.endEllipse(at: point)
        
//        guard var next = canvas.nextQuad else { return }
//
//        let point = firstTouch.metalLocation(in: canvas)
//        next.end(at: point)
//
//        // End and display the quad as an ellipse where you currently drag.
//        next.endAsCircle(at: point)
//        canvas.currentPath?.quads = [next]
    }
    
    public func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
    }
    
    public func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
    }
    
}
