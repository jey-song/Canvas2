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

struct Quad {
    
    // MARK: Variables
    
    var vertices: [Vertex]
    
    
    // MARK: Initialization
    
    init() {
        self.vertices = [
            Vertex(position: CGPoint(x: -0.5, y: -0.5), color: .black),
            Vertex(position: CGPoint(x: -0.5, y: 0), color: .black),
            Vertex(position: CGPoint(x: 0.5, y: -0.5), color: .black),
            Vertex(position: CGPoint(x: 0.5, y: 0), color: .black),
        ]
    }
    
    init(start: CGPoint) {
        self.vertices = [
            Vertex(position: start, color: .blue),
            Vertex(position: CGPoint(x: start.x - 0.05, y: start.y - 0.05), color: .blue),
            Vertex(position: CGPoint(x: start.x + 0.05, y: start.y), color: .blue),
            Vertex(position: CGPoint(x: start.x, y: start.y - 0.05), color: .blue),
        ]
    }
    
    
    
    // MARK: Functions
    
    func render(encoder: MTLRenderCommandEncoder) {
        guard let buffer = dev.makeBuffer(
            bytes: self.vertices,
            length: self.vertices.count * MemoryLayout<Vertex>.stride,
            options: []) else { return }
        
        let vertCount = buffer.length / MemoryLayout<Vertex>.stride
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertCount)
    }
}
