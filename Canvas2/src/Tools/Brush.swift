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
    
    internal var size: CGFloat {
        didSet {
            self.size = Brush.configureBrushSize(from: self.size)
        }
    }
    
    internal var color: UIColor
    
    internal var texture: MTLTexture?
    
    
    
    
    
    // MARK: Initialization
    
    init(size s: CGFloat, color c: UIColor) {
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
    
    
    /** Changes the brush size to be more metal friendly for the current drawing system. */
    internal static func configureBrushSize(from s: CGFloat) -> CGFloat {
        return (s / 100) * 4
    }
    
    /** Makes a copy of this brush. */
    func copy() -> Brush {
        var b: Brush = Brush(size: self.size, color: self.color)
        b.texture = self.texture
        return b
    }
}
