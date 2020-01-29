//
//  Brush.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/15/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/** A customizable brush that determines how curves drawn on the canvas will look. */
public struct Brush: Codable {
    
    // MARK: Variables
    
    internal var canvas: Canvas?
    
    internal var name: String
    
    public var size: CGFloat
    
    public var color: UIColor
    
    public var opacity: CGFloat
    
    internal var textureName: String?
    
    internal var isEraser: Bool
    
    internal var pipeline: MTLRenderPipelineState!
    
    
    
    
    
    // MARK: Initialization
    
    public init(
        canvas: Canvas?,
        name: String,
        size: CGFloat = 10.0,
        color: UIColor = UIColor.black,
        opacity: CGFloat = 1.0,
        textureName: String? = nil,
        isEraser: Bool = false
    ) {
        self.canvas = canvas
        self.name = name
        self.size = size
        self.color = color
        self.opacity = opacity
        self.textureName = textureName
        self.isEraser = isEraser
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: BrushCodingKeys.self)
        name = try container?.decodeIfPresent(String.self, forKey: .name) ?? "defaultBrush"
        size = try container?.decodeIfPresent(CGFloat.self, forKey: .size) ?? 10
        
        let c = try container?.decodeIfPresent([CGFloat].self, forKey: .color) ?? [0,0,0,1]
        color = UIColor(red: c[0], green: c[1], blue: c[2], alpha: c[3])
        opacity = try container?.decodeIfPresent(CGFloat.self, forKey: .opacity) ?? 1.0
        textureName = try container?.decodeIfPresent(String?.self, forKey: .textureID) ?? ""
        isEraser = try container?.decodeIfPresent(Bool.self, forKey: .isEraser) ?? false
        name = try container?.decodeIfPresent(String.self, forKey: .name) ?? "defaultBrush"
    }
    
    
    
    
    // MARK: Functions
    
    /** Sets up the pipeline for this brush. */
    internal mutating func setupPipeline() {
        guard let device = canvas?.device else { return }
        guard let lib = getLibrary(device: device) else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        self.pipeline = buildRenderPipeline(device: device, vertProg: vertProg, fragProg: fragProg)
    }
    
    /** Makes a copy of this brush. */
    func copy() -> Brush {
        var b: Brush = Brush(
            canvas: self.canvas,
            name: self.name,
            size: self.size,
            color: self.color,
            opacity: self.opacity,
            isEraser: self.isEraser
        )
        b.textureName = self.textureName
        b.pipeline = self.pipeline
        return b
    }
    
    
    // MARK: Decoding
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BrushCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(size, forKey: .size)
        
        let c = color.rgba
        try container.encode([
            c.red, c.green, c.blue, c.alpha
        ], forKey: .color)
        try container.encode(opacity, forKey: .opacity)
        
        try container.encode(textureName, forKey: .textureID)
        try container.encode(isEraser, forKey: .isEraser)
    }
    
}
