//
//  Events.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/22/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit
import Metal
import MetalKit

/** A set of methods that get called at different points throughout the lifecycle of the canvas. */
public protocol CanvasEvents {
    
    /** Called while the user is currently drawing on the canvas. */
    func isDrawing(element: Element, on canvas: Canvas)
    
    /** Called when the user stops drawing on the canvas. */
    func stoppedDrawing(element: Element, on canvas: Canvas)
    
    /** Called whenever you change a brush. */
    func didChangeBrush(to brush: Brush)
    
    /** Called when you change the tool. */
    func didChaneTool(to tool: Tool)
    
}
