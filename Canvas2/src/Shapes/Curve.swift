//
//  Curve.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/11/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/** Represents a single curve that can be drawn on the canvas. */
public struct Curve {
    
    // MARK: - Internals
    var lines: [Line]
    
    // MARK: - Computed
    var numLines: Int {
        return self.lines.count
    }
    
    
    
    
    init() {
        self.lines = []
    }
    
    /** Adds a new point onto the curve. */
    mutating func add(line: Line) {
        // TODO: When drawing curves (even just simple ones) you should really
        // be drawing a rectangle so that you can account for line width.
        self.lines.append(line)
    }
    
    /** A helper function that takes an MTLRenderEncoder as a paramater and uses it to draw the curve on the screen. */
    public func render(encoder enc: MTLRenderCommandEncoder) {
        // GO through each line and basically allow it to handle drawing line strips
        // between each of its points. That way each individual curve is separated.
        for line in lines {
            line.render(encoder: enc)
        }
    }
}
