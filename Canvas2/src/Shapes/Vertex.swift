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

/** Data structure that goes directly to the shader functions. Do not change the order of the variables without
 also changing the order int he Shader.metal file. */
struct Vertex: Codable {
    
    // MARK: Variables (IMPORTANT: DO NOT change the order of these variables)
    
    var position: SIMD4<Float>
    
    var color: SIMD4<Float>
    
    var texture: SIMD2<Float>
    
    var erase: Float
    
    
    // MARK: Initialization
    
    init(position: CGPoint, color: UIColor, texture: SIMD2<Float>? = nil) {
        let x = Float(position.x)
        let y = Float(position.y)
        let rgba = color.rgba
        let toFloat = [rgba.red, rgba.green, rgba.blue, rgba.alpha].map { a -> Float in
            return Float(a)
        }
        
        self.position = SIMD4<Float>(x: x, y: y, z: 0, w: 1)
        self.color = SIMD4<Float>(x: toFloat[0], y: toFloat[1], z: toFloat[2], w: toFloat[3])
        self.texture = texture ?? SIMD2<Float>(x: -1, y: -1)
        self.erase = Float(0.0)
    }
    
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        var container = try? decoder.unkeyedContainer()
        
        let data = try container?.decodeIfPresent(Data.self) ?? Data()
        let decString = (String(data: data, encoding: .utf8) ?? "0,0,0,1*0,0,0,1*-1,-1*0.0").split(separator: "*")
        let posString = decString[0]
        let colString = decString[1]
        let texString = decString[2]
        let eraseString = decString[3]
        
        let posArr = posString.split(separator: ",")
        let colArr = colString.split(separator: ",")
        let texArr = texString.split(separator: ",")
        
        self.position = SIMD4<Float>(x: Float(posArr[0]) ?? 0.0, y: Float(posArr[1]) ?? 0.0, z:0, w: 1)
        self.color = SIMD4<Float>(x: Float(colArr[0]) ?? 0.0, y: Float(colArr[1]) ?? 0.0, z: Float(colArr[2]) ?? 0.0, w: Float(colArr[3]) ?? 0.0)
        self.texture = SIMD2<Float>(x: Float(texArr[0]) ?? 0.0, y: Float(texArr[1]) ?? 0.0)
        self.erase = Float(eraseString) ?? 0.0
    }
    
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        let posString = "\(position.x),\(position.y)"
        let colString = "\(color.x),\(color.y),\(color.z),\(color.w)"
        let texString = "\(texture.x),\(texture.y)"
        let eraseString = "\(erase)"
        
        let encodeString = "\(posString)*\(colString)*\(texString)*\(eraseString)"
        let data = encodeString.data(using: .utf8)
        try container.encode(data)
    }
    
    
    
    
}
