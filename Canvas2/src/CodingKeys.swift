//
//  CodingKeys.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/28/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


internal enum BrushCodingKeys: CodingKey {
    case name
    case size
    case color
    case opacity
    case isEraser
    case textureID
    case registeredTextures
}

internal enum LayerCodingKeys: CodingKey {
    case elements
    case isLocked
    case isHidden
}

internal enum VertexCodingKeys: CodingKey {
    case position
    case color
    case texture
    case erase
}

internal enum QuadCodingKeys: CodingKey {
    case vertices
    case start
    case end
    case c
    case d
    case startForce
    case endForce
}

internal enum ElementCodingKeys: CodingKey {
    case brushID
    case quads
}

internal enum ToolCodingKeys: CodingKey {
    case name
}

internal enum CanvasCodingKeys: CodingKey {
    case canvasLayers
    case force
    case registeredTextures
    case registeredBrushes
    case currentBrush
    case maximumForce
    case stylusOnly
    case canvasColor
    case currentLayer
}
