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


/** A customizable brush that draws simple curves on the canvas. */
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
