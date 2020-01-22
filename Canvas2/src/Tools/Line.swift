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
        guard let canvas = self.canvas else { return }
        let point = firstTouch.metalLocation(in: canvas)

        // When drawing a line, you only need one quad to work with.
        let quad = Quad(start: point)
        canvas.currentPath.startPath(quad: quad)
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = self.canvas else { return }
        guard canvas.currentPath != nil else { print("No current path"); return }
        
        let point = firstTouch.metalLocation(in: canvas)
        canvas.currentPath.endLine(at: point)
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
