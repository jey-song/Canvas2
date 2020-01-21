//
//  Quad.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/14/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import UIKit

/** A four-sided shape that gets rendered on the screen as two adjacent triangles. */
struct Quad {
    
    // MARK: Variables

    var brush: Brush

    var vertices: [Vertex]
    
    var start: CGPoint
    
    var end: CGPoint
    
    var c: CGPoint
    
    var d: CGPoint
    
    var startForce: CGFloat
    
    var endForce: CGFloat
    
    var buffer: MTLBuffer?
    
    
    
    // MARK: Initialization
    
    init(brush: Brush) {
        self.vertices = []
        self.start = CGPoint()
        self.end = CGPoint()
        self.c = CGPoint()
        self.d = CGPoint()
        self.brush = brush
        self.startForce = 1.0
        self.endForce = 1.0
    }
    
    init(start: CGPoint, brush: Brush) {
        self.vertices = []
        self.start = start
        self.end = CGPoint()
        self.c = CGPoint()
        self.d = CGPoint()
        self.brush = brush
        self.startForce = 1.0
        self.endForce = 1.0
    }
    
    
    // MARK: Functions
    
    mutating func makeBuffer() {
        self.buffer = dev.makeBuffer(
            bytes: self.vertices,
            length: self.vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
    }
    
    /** Sets the ending position of this quad and promptly computes the rectangular shape
     needed to display it on screen. It really just computes two triangles at the end of the day. */
    mutating func end(at: CGPoint, prevA: CGPoint? = nil, prevB: CGPoint? = nil) {
        self.end = at
        
        let size = self.brush.size / 2
        let color = self.brush.color
        let texture = self.brush.texture
        
        // Compute the quad vertices ABCD.
        let perpendicular = self.start.perpendicular(other: self.end).normalize()
        var A = self.start + (perpendicular * size * self.startForce)
        var B = self.start - (perpendicular * size * self.startForce)
        let C = self.end + (perpendicular * size * self.endForce)
        let D = self.end - (perpendicular * size * self.endForce)
        
        // Use the previous quad's points to avoid gaps.
        if let pA = prevA, let pB = prevB {
            A = pA
            B = pB
        }
        self.c = C
        self.d = D

        // Place the quad points into the vertices array to form two triangles.
        self.vertices = [
            // Triangle 1
            Vertex(position: A, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
            Vertex(position: B, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: -0.5) : nil),
            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: 0) : nil),

            // Triangle 2
            Vertex(position: B, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: -0.5) : nil),
            Vertex(position: D, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: 0) : nil),
        ]
        self.makeBuffer()
    }
    
    
    /** Finalizes the data on this quad as a perfect rectangle from the given starting point. */
    mutating func endAsRectangle(at: CGPoint) {
        self.end = at
        let color = self.brush.color
        let texture = self.brush.texture
        
        // Compute the rectangle from the starting point to the end point.
        // Remember that the end coordinates can be behind the start.
        var corner1 = self.start
        var corner2 = self.start
        
        // Condition 1: Going from bottom left to top right.
        if self.start.x < self.end.x && self.start.y < self.end.y {
            let xDist = self.end.x - self.start.x
            let yDist = self.end.y - self.start.y
            corner2.x += xDist
            corner1.y += yDist
        }
        // Condition 2: Top left to bottom right.
        else if self.start.x < self.end.x && self.start.y > self.end.y {
            let xDist = self.end.x - self.start.x
            let yDist = self.start.y - self.end.y
            corner2.x += xDist
            corner1.y -= yDist
        }
        // Condition 3: Top right to bottom left.
        else if self.start.x > self.end.x && self.start.y > self.end.y {
            let xDist = self.start.x - self.end.x
            let yDist = self.start.y - self.end.y
            corner2.x -= xDist
            corner1.y -= yDist
        }
        // Condition 4: Bottom right to top left.
        else if self.start.x > self.end.x && self.start.y < self.end.y {
            let xDist = self.start.x - self.end.x
            let yDist = self.end.y - self.start.y
            corner2.x -= xDist
            corner1.y += yDist
        }
        
        // Apply the corners to the vertices array to form two triangles,
        // which will come together to form one rectangle on the screen.
        self.vertices = [
            Vertex(position: self.end, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
            Vertex(position: corner2, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: -0.5) : nil),
            Vertex(position: self.start, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: 0) : nil),

            Vertex(position: self.start, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
            Vertex(position: self.end, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: -0.5) : nil),
            Vertex(position: corner1, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: 0) : nil),
        ]
    }
    
    
    /** Finalizes a straight line as a quad. */
    mutating func endAsLine(at: CGPoint) {
        self.end = at
        
        // Create the coordinates of the two triangles.
        let size = self.brush.size / 2
        let color = self.brush.color
        let texture = self.brush.texture
        
        let perpendicular = self.start.perpendicular(other: self.end).normalize()
        var A: CGPoint = self.start
        var B: CGPoint = self.end
        var C: CGPoint = self.end
        var D: CGPoint = self.start
        
        // Based on the rotation, compute the four corners of the quad.
        // Condition 1: Bottom left to top right.
        if self.start.x < self.end.x && self.start.y < self.end.y {
            A.x -= (perpendicular * size).x
            A.y += (perpendicular * size).x
            
            B.x -= (perpendicular * size).x
            B.y += (perpendicular * size).x
            
            C.x += (perpendicular * size).x
            C.y -= (perpendicular * size).x
            
            D.x += (perpendicular * size).x
            D.y -= (perpendicular * size).x
        }
        // Condition 2: Top left to bottom right.
        else if self.start.x < self.end.x && self.start.y > self.end.y {
            A.x += (perpendicular * size).x
            A.y += (perpendicular * size).x
            
            B.x += (perpendicular * size).x
            B.y += (perpendicular * size).x
            
            C.x -= (perpendicular * size).x
            C.y -= (perpendicular * size).x
            
            D.x -= (perpendicular * size).x
            D.y -= (perpendicular * size).x
        }
        // Condition 3: Top right to bottom left.
        else if self.start.x > self.end.x && self.start.y > self.end.y {
            A.x += (perpendicular * size).x
            A.y -= (perpendicular * size).x
            
            B.x += (perpendicular * size).x
            B.y -= (perpendicular * size).x
            
            C.x -= (perpendicular * size).x
            C.y += (perpendicular * size).x
            
            D.x -= (perpendicular * size).x
            D.y += (perpendicular * size).x
        }
        // Condition 4: Bottom right to top left.
        else if self.start.x > self.end.x && self.start.y < self.end.y {
            A.x -= (perpendicular * size).x
            A.y -= (perpendicular * size).x
            
            B.x -= (perpendicular * size).x
            B.y -= (perpendicular * size).x
            
            C.x += (perpendicular * size).x
            C.y += (perpendicular * size).x
            
            D.x += (perpendicular * size).x
            D.y += (perpendicular * size).x
        }
        
        // Set the vertices of the line quad.
        self.vertices = [
            // Triangle 1
            Vertex(position: A, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
            Vertex(position: B, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: -0.5) : nil),
            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: 0) : nil),

            // Triangle 2
            Vertex(position: A, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: -0.5) : nil),
            Vertex(position: D, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: 0) : nil),
        ]
    }
    
    
    /** Ends a quad as a circle (but technically using triangles). */
    mutating func endAsCircle(at: CGPoint) {
        self.end = at
        
        let color = self.brush.color
        let texture = self.brush.texture
        var verts: [Vertex] = [Vertex(position: self.start, color: color)]
        
        /** Creates points around a circle. It's just a formula for degrees to radians. */
        func rads(forDegree d: Int) -> CGFloat {
            // 7 turns out to be the magic number here :)
            return (7 * CGFloat.pi * CGFloat(d)) / 180
        }
        
        // Create vertices for the circle.
        for i in 0..<720 {
            // Add the previous point so that the triangle can reconnect to
            // the start point.
            if i > 0 && verts.count > 0 && i % 2 == 0 {
                let last = verts[i - 1]
                verts.append(last)
            }
            
            // Calculate the point at the distance around the circle.
            let _x = cos(rads(forDegree: i)) * abs(self.end.x - self.start.x)
            let _y = sin(rads(forDegree: i)) * abs(self.end.y - self.start.y)
            let pos: CGPoint = CGPoint(x: self.start.x + _x, y: self.start.y + _y)
            verts.append(Vertex(position: pos, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil))
        }
        self.vertices = verts
    }
    
    
    /** Renders this quad onto the screen using the given encoder. */
    func render(encoder: MTLRenderCommandEncoder) {
        guard let buffer = dev.makeBuffer(
            bytes: self.vertices,
            length: self.vertices.count * MemoryLayout<Vertex>.stride,
            options: []) else { return }

        let vertCount = buffer.length / MemoryLayout<Vertex>.stride
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertCount)
    }
}
