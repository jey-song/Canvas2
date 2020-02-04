//
//  Line.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/16/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit


/** A tool that draws a straight line from the initial touch point to the end touch point. */
public struct Line: Tool {
    
    // MARK: Variables
    
    public var name: String
    
    public var canvas: Canvas?
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas) {
        self.canvas = canvas
        self.name = "line"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: ToolCodingKeys.self)
        name = try container?.decodeIfPresent(String.self, forKey: .name) ?? "line"
    }
    
    
    // MARK: Functions
    
    public func beginTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        let point = firstTouch.metalLocation(in: canvas)

        // When drawing a line, you only need one quad to work with.
        let quad = Quad(start: point)
        canvas.currentPath.startPath(quad: quad)
        return true
    }
    
    public func moveTouch(_ firstTouch: UITouch, _ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.currentPath != nil else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        let point = firstTouch.metalLocation(in: canvas)
        canvas.currentPath.end(at: point, as: .line)
        return true
    }
    
    public func endTouch(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    public func cancelTouch(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let canvas = self.canvas else { return false }
        guard canvas.isOnValidLayer() else { return false }
        
        // Clear the current drawing curve.
        canvas.rebuildBuffer()
        canvas.currentPath?.closePath()
        return true
    }
    
    // MARK: Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ToolCodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    
}
