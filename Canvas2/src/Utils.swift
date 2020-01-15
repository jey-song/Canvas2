//
//  Utils.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/15/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import CoreGraphics

/** Changes the brush size to be more metal friendly for the current drawing system. */
internal func computeMetalSize(from s: CGFloat) -> CGFloat {
    return (s / 100) * 4
}
