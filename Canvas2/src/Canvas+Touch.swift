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
//        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        
        // Get the position of the current touch and add it to the curve.
        // That curve will only exist and be editable while the touch is
        // active.
        let position = touch.metalLocation(in: self)
        if self.nextCurve == nil { self.nextCurve = Curve() }
        print("Touches began! \(position)")
        
        self.nextCurve!.color = self.currentColor
        self.nextCurve!.add(x: position.x, y: position.y)
        
        // Get the vertex data for that point and set up the buffer.
        guard let next = self.nextCurve else { return }
        let dataLength = next.numPoints * MemoryLayout.size(ofValue: next.points[0])
        
        guard let dev = self.device else { return }
        let options = MTLResourceOptions(arrayLiteral: [])
        guard let buffer = dev.makeBuffer(bytes: next.points, length: dataLength, options: options) else { return }
        
        // Set the point buffer and append the curve to this canvas.
        nextCurve!.setBuffer(buffer: buffer)
        self.curves.append(nextCurve!)
        self.commands = dev.makeCommandQueue()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        
        // Get the position of the current touch and add it to the curve.
        // That curve will only exist and be editable while the touch is
        // active.
        let position = touch.metalLocation(in: self)
        print("Touches moved! \(position)")
        
        // You don't need to color again, just make sure there is a curve
        // to draw with. Add the touch location.
        if self.nextCurve == nil {
            self.nextCurve = Curve()
            self.nextCurve?.color = self.currentColor
        }
        self.nextCurve!.add(x: position.x, y: position.y)
        
        // Get the vertex data for that point and set up the buffer.
        guard let next = self.nextCurve else { return }
        let dataLength = next.numPoints * MemoryLayout.size(ofValue: next.points[0])
        
        guard let dev = self.device else { return }
        let options = MTLResourceOptions(arrayLiteral: [])
        guard let buffer = dev.makeBuffer(bytes: next.points, length: dataLength, options: options) else { return }
        
        // Set the point buffer and append the curve to this canvas.
        nextCurve!.setBuffer(buffer: buffer)
        self.curves.append(nextCurve!)
        self.commands = dev.makeCommandQueue()
        
        draw()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        guard let touch = touches.first else { return }
//        let position = touch.metalLocation(in: self)
        
        // When you are done drawing the line, add it as a curve to
        // the canvas and clear it so you can make a new curve.
        self.curves.append(self.nextCurve!)
        
        draw()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
}
