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
            self.size = computeMetalSize(from: self.size)
        }
    }
    
    internal var color: UIColor
    
    
    /** The default brush that the canvas uses. */
    static let Default: Brush = {
        return Brush(size: 10, color: .black)
    }()
    
    
    
    // MARK: Initialization
    
    init(size s: CGFloat, color c: UIColor) {
        self.size = computeMetalSize(from: s)
        self.color = c
    }
    
    
    // MARK: Functions
    
    func copy() -> Brush {
        let b: Brush = Brush(size: self.size, color: self.color)
        return b
    }
}
