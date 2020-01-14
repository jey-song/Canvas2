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
    
    internal var color: UIColor
    
    
    
    // MARK: - Constructors
    
    init(size s: Float, color c: UIColor) {
        self.size = s
        self.color = c
    }
    
    init() {
        self.init(size: 10, color: .black)
    }
    
    
}
