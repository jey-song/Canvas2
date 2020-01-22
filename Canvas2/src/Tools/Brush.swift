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
public struct Brush {
    
    // MARK: Variables
    
    internal var name: String
    
    internal var size: CGFloat {
        didSet {
            self.size = Brush.configureBrushSize(from: self.size)
        }
    }
    
    internal var color: UIColor
    
    internal var texture: MTLTexture?
    
    internal var pipeline: MTLRenderPipelineState!
    
    
    
    
    
    // MARK: Initialization
    
    init(name: String, size s: CGFloat, color c: UIColor) {
        self.name = name
        self.size = Brush.configureBrushSize(from: s)
        self.color = c
        self.texture = nil
    }
    
    
    // MARK: Functions
    
    /** Sets the texture on this brush using a texture name that has already been added to the canvas. */
    public mutating func setTexture(name: String, canvas: Canvas) {
        guard let txr = canvas.getTexture(withName: name) else { return }
        self.texture = txr
    }
    
    
    /** Sets up the pipeline for this brush. */
    internal mutating func setupPipeline() {
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        self.pipeline = buildRenderPipeline(vertProg: vertProg, fragProg: fragProg, modesOn: false)
        print("Created brush specific pipeline for brush: \(name).")
    }
    
    /** Changes the brush size to be more metal friendly for the current drawing system. */
    internal static func configureBrushSize(from s: CGFloat) -> CGFloat {
        return (s / 100) * 4
    }
    
    /** Makes a copy of this brush. */
    func copy() -> Brush {
        var b: Brush = Brush(name: self.name, size: self.size, color: self.color)
        b.texture = self.texture
        b.pipeline = self.pipeline
        return b
    }
}
