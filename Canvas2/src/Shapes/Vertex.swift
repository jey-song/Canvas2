//
//  Vertex.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/14/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import simd


struct Vertex {
    
    // MARK: Variables (IMPORTANT: DO NOT change the order of these variables)
    
    var position: SIMD4<Float>
    
    var color: SIMD4<Float>
    
    
    // MARK: Initialization
    
    init(position: CGPoint, color: UIColor) {
        let x = Float(position.x)
        let y = Float(position.y)
        let rgba = color.rgba
        let toFloat = [rgba.red, rgba.green, rgba.blue, rgba.alpha].map { a -> Float in
            return Float(a)
        }
        
        self.position = SIMD4<Float>(x: x, y: y, z: 0, w: 1)
        self.color = SIMD4<Float>(x: toFloat[0], y: toFloat[1], z: toFloat[2], w: toFloat[3])
    }
    
}
