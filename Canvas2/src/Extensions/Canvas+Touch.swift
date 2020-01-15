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
        let point = touch.metalLocation(in: self)
        
        // Start a new quad when a touch is down.
        nextQuad = Quad(start: point, brush: self.currentBrush.copy())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.metalLocation(in: self)
        
        // Every time you move, end the current quad and that position.
        guard var next = nextQuad else { return }
        next.end(at: point)
        
        // Add that finalized quad onto the list of quads on the canvas.
        quads.append(next)
        
        // Start the next quad from the end position, in case the touch is still moving.
        nextQuad = Quad(start: point, brush: self.currentBrush.copy())
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Close the current quad, no touches on the screen.
        nextQuad = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Close the current quad, no touches on the screen.
        nextQuad = nil
    }
}
