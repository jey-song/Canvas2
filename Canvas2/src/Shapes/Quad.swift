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
    
    /** Sets the ending position of this quad and promptly computes the rectangular shape
     needed to display it on screen. It really just computes two triangles at the end of the day. */
    mutating func end(at: CGPoint, prevA: CGPoint? = nil, prevB: CGPoint? = nil) {
        self.end = at
        
        let size = self.brush.size / 2
        let color = self.brush.color
        
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
            Vertex(position: A, color: color),
            Vertex(position: B, color: color),
            Vertex(position: C, color: color),

            // Triangle 2
            Vertex(position: B, color: color),
            Vertex(position: C, color: color),
            Vertex(position: D, color: color),
        ]
    }
    
    
    /** Finalizes the data on this quad as a perfect rectangle from the given starting point. */
    mutating func endAsRectangle(at: CGPoint) {
        self.end = at
        let color = self.brush.color
        
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
            Vertex(position: self.end, color: color),
            Vertex(position: corner2, color: color),
            Vertex(position: self.start, color: color),

            Vertex(position: self.start, color: color),
            Vertex(position: self.end, color: color),
            Vertex(position: corner1, color: color),
        ]
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
