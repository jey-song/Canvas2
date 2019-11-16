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
    
    // MARK: - Internals
    internal var size: Float
    internal var opacity: Float
    internal var color: UIColor
    
    
    
    // MARK: - Constructors
    init(size s: Float, opacity o: Float, color c: UIColor) {
        self.size = s
        self.opacity = o
        self.color = c
    }
    
    init() {
        self.init(size: 5, opacity: 1, color: .black)
    }
    
    
}
