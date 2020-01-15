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
    
    internal var size: CGFloat
    
    internal var color: UIColor
    
    
    static let Default: Brush = {
        return Brush(size: 10, color: .black)
    }()
    
    
    
    // MARK: Initialization
    
    init(size s: CGFloat, color c: UIColor) {
        self.size = s / (s + 20) // <-- 20 just seemed like a nice number while testing.
        self.color = c
    }
    
    
    // MARK: Functions
    
    func copy() -> Brush {
        let b: Brush = Brush(size: self.size, color: self.color)
        return b
    }
}
