//
//  Canvas+Touch.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/12/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public extension Canvas {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true && touch.type != .pencil && touch.type != .stylus {
            return
        }
        
        // Let the current tool handle manipulating point and quad/vertex data.
        if self.currentTool.beginTouch(touch, touches, with: event) {
            self.canvasDelegate?.isDrawing(element: currentPath, on: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true && touch.type != .pencil && touch.type != .stylus {
            return
        }
        
        // Allow the current tool to handle movement across the screen.
        if self.currentTool.moveTouch(touch, touches, with: event) {
            self.canvasDelegate?.isDrawing(element: currentPath, on: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true && touch.type != .pencil && touch.type != .stylus {
            return
        }
        
        if self.currentTool.endTouch(touches, with: event) {
            self.canvasDelegate?.stoppedDrawing(element: currentPath, on: self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Check for stylus only touches.
        if self.stylusOnly == true && touch.type != .pencil && touch.type != .stylus {
            return
        }
        
        if self.currentTool.cancelTouch(touches, with: event) {
            self.canvasDelegate?.stoppedDrawing(element: currentPath, on: self)
        }
    }
}
