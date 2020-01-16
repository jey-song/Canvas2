//
//  Tool.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

/** A protocol for defining a tool, which determines how to manipulate the vertex/quad data on the canvas. */
public protocol Tool {
    
    // MARK: Variables
    
    var canvas: Canvas? { get set }
    
    
    // MARK: Functions
    
    /** Called when this tool first hits the canvas. */
    func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?)
    
    /** Called when this tool starts to move. */
    func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?)
    
    /** Called when this tool is no longer touching the canvas. */
    func endTouch(_ touches: Set<UITouch>, with event: UIEvent?)
    
    /** Called when this tool stops touching the canvas w/o help from the user. */
    func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?)
    
    
}
