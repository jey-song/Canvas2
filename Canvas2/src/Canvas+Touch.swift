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
        
        // Get the position of the current touch and add it to the curve.
        // That curve will only exist and be editable while the touch is
        // active.
        let position = touch.metalLocation(in: self)
        
        var line = Line()
        line.color = currentColor
        line.add(point: position)
        nextCurve.append(line)
        
        // Add a curve, which will sit at the last index in the array and
        // will be referenced as long as the touch is down.
        curves.append(Curve())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // We need a reference to the last line and curve in the arrays.
        // These are generated upon a touch (touchesBegan function) so
        // you can be sure they will exist by the time you reach here.
        guard var lastLine = nextCurve.last else { return }
        guard var lastCurve = curves.last else { return }
        
        // Get the position of the current touch and add it to the curve.
        // Add on the new point onto the line, then make sure the curve
        // is updated to have that updated line segment.
        let position = touch.metalLocation(in: self)
        lastLine.add(point: position)
        
        // Make sure the entire curve that you are drawing knows about
        // the last line you just drew. Then update the last curve.
        nextCurve.append(lastLine)
        lastCurve.add(line: lastLine)
        curves[curves.count - 1] = lastCurve
        commands = dev.makeCommandQueue()
        
        // Update the canvas.
        draw()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
