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
struct Quad: Codable {
    
    // MARK: Variables

    var vertices: [Vertex]
    
    var start: CGPoint
    
    
    
    // MARK: Initialization
    
    init(start: CGPoint) {
        self.vertices = []
        self.start = start
    }
    
    public init(from decoder: Decoder) throws {
        var container = try? decoder.unkeyedContainer()
        
        self.vertices = try container?.decode([Vertex].self) ?? []
        self.start = CGPoint.zero
    }
    
    
    // MARK: Functions
    
    /** Sets the ending position of this quad and promptly computes the rectangular shape
     needed to display it on screen. It really just computes two triangles at the end of the day. */
    mutating func end(
        at end: CGPoint,
        brush: Brush,
        prevA: CGPoint? = nil,
        prevB: CGPoint? = nil,
        endForce: CGFloat = 1.0
    ) -> (_: CGPoint, _:CGPoint)
    {
        let size = (((brush.size / 100) * 4) / 2) / 50
        let color = brush.color
        let texture = brush.textureName
        
        // Compute the quad vertices ABCD.
        let perpendicular = self.start.perpendicular(other: end).normalize()
        var A = self.start + (perpendicular * size * endForce)
        var B = self.start - (perpendicular * size * endForce)
        let C = end + (perpendicular * size * endForce)
        let D = end - (perpendicular * size * endForce)
        
        // Use the previous quad's points to avoid gaps.
        if let pA = prevA, let pB = prevB {
            A = pA
            B = pB
        }
        
        // Place the quad points into the vertices array to form two triangles.
        self.vertices = [
            Vertex(position: end, size: 20.0, color: color)
//            // Triangle 1
//            Vertex(position: A, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
//            Vertex(position: B, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: -0.5) : nil),
//            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: 0) : nil),
//
//            // Triangle 2
//            Vertex(position: B, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
//            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: -0.5) : nil),
//            Vertex(position: D, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: 0) : nil),
        ]
        
        // TODO: Construct a better box so that you only need to work with 4 vertices.
        // This may also be a good chance to introduce brush shapes.
        // TODO: Maybe instead of drawing triangles, you really just need to draw points.
        // Then for each point, set the texture to be a combination of the brush shape and
        // brush texture. Or maybe even just figure out how to place an image on a point.
        return (C, D)
    }
    
    
    /** Finalizes the data on this quad as a perfect rectangle from the given starting point. */
    mutating func endAsRectangle(at end: CGPoint, brush: Brush) {
        let color = brush.color
        let texture = brush.textureName
        
        // Compute the rectangle from the starting point to the end point.
        // Remember that the end coordinates can be behind the start.
        var corner1 = self.start
        var corner2 = self.start
        
        // Condition 1: Going from bottom left to top right.
        if self.start.x < end.x && self.start.y < end.y {
            let xDist = end.x - self.start.x
            let yDist = end.y - self.start.y
            corner2.x += xDist
            corner1.y += yDist
        }
        // Condition 2: Top left to bottom right.
        else if self.start.x < end.x && self.start.y > end.y {
            let xDist = end.x - self.start.x
            let yDist = self.start.y - end.y
            corner2.x += xDist
            corner1.y -= yDist
        }
        // Condition 3: Top right to bottom left.
        else if self.start.x > end.x && self.start.y > end.y {
            let xDist = self.start.x - end.x
            let yDist = self.start.y - end.y
            corner2.x -= xDist
            corner1.y -= yDist
        }
        // Condition 4: Bottom right to top left.
        else if self.start.x > end.x && self.start.y < end.y {
            let xDist = self.start.x - end.x
            let yDist = end.y - self.start.y
            corner2.x -= xDist
            corner1.y += yDist
        }
        
        // Apply the corners to the vertices array to form two triangles,
        // which will come together to form one rectangle on the screen.
//        self.vertices = [
//            Vertex(position: end, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
//            Vertex(position: corner2, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: -0.5) : nil),
//            Vertex(position: self.start, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: 0) : nil),
//
//            Vertex(position: self.start, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
//            Vertex(position: end, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: -0.5) : nil),
//            Vertex(position: corner1, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: 0) : nil),
//        ]
    }
    
    
    /** Finalizes a straight line as a quad. */
    mutating func endAsLine(at end: CGPoint, brush: Brush) {
        // Create the coordinates of the two triangles.
        let size = (((brush.size / 100) * 4) / 2) / 50
        let color = brush.color
        let texture = brush.textureName
        
        let perpendicular = self.start.perpendicular(other: end).normalize()
        var A: CGPoint = self.start
        var B: CGPoint = end
        var C: CGPoint = end
        var D: CGPoint = self.start
        
        // Based on the rotation, compute the four corners of the quad.
        // Condition 1: Bottom left to top right.
        if self.start.x < end.x && self.start.y < end.y {
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
        else if self.start.x < end.x && self.start.y > end.y {
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
        else if self.start.x > end.x && self.start.y > end.y {
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
        else if self.start.x > end.x && self.start.y < end.y {
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
//            Vertex(position: A, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
//            Vertex(position: B, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: -0.5) : nil),
//            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: 0.5, y: 0) : nil),
//
//            // Triangle 2
//            Vertex(position: A, color: color, texture: texture != nil ? SIMD2<Float>(x: 0, y: 0) : nil),
//            Vertex(position: C, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: -0.5) : nil),
//            Vertex(position: D, color: color, texture: texture != nil ? SIMD2<Float>(x: -0.5, y: 0) : nil),
        ]
    }
    
    
    /** Ends a quad as a circle (but technically using triangles). */
    mutating func endAsCircle(at end: CGPoint, brush: Brush) {
        let color = brush.color
        let texture = brush.textureName
        var verts: [Vertex] = [Vertex(position: self.start, color: color)]
        
        /** Creates points around a circle. It's just a formula for degrees to radians. */
        func rads(forDegree d: Int) -> CGFloat {
            // 7 turns out to be the magic number here :)
            return (7 * CGFloat.pi * CGFloat(d)) / 180
        }
        
        // Keep track of the texture position for each vertex in the circle.
        let poses: [(x: Float, y: Float)] = [
            (0, 0),
            (0.5, -0.5),
            (0.5, 0),
            (0, 0),
            (-0.5, -0.5),
            (-0.5, 0)
        ]
        var pose: Int = 0
        
        // Create vertices for the circle.
        for i in 0..<720 {
            // Add the previous point so that the triangle can reconnect to
            // the start point.
            if i > 0 && verts.count > 0 && i % 2 == 0 {
                let last = verts[i - 1]
                verts.append(last)
            }
            
            // Calculate the point at the distance around the circle.
            let _x = cos(rads(forDegree: i)) * abs(end.x - self.start.x)
            let _y = sin(rads(forDegree: i)) * abs(end.y - self.start.y)
            let pos: CGPoint = CGPoint(x: self.start.x + _x, y: self.start.y + _y)
//            verts.append(Vertex(position: pos, color: color, texture: texture != nil ? SIMD2<Float>(x: poses[pose].x, y: poses[pose].y) : nil))
            
            // Update the pose.
            pose = (pose == poses.count - 1) ? 0 : pose + 1
        }
        self.vertices = verts
    }
    
    
    
    // MARK: Encoding
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(vertices)
    }
    
    
}
