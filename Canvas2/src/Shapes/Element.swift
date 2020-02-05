//
//  Element.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/19/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** An element is a manager for a group of quads on a layer of the canvas. */
public struct Element: Codable {
    
    // MARK: Variables
    
    // --> Internal
    
    internal var brushName: String
    internal var vertices: [Vertex]
    internal var start: CGPoint
    
    internal var isFreeHand: Bool
    
    internal var canvas: Canvas?
    internal var buffer: MTLBuffer?
    
    
    
    // --> Public
    
    /** Returns the number of quad segments that make up this element. */
    public var length: Int {
        return vertices.count
    }
    
    
    
    // MARK: Initialization
    
    init(_ verts: [Vertex], canvas: Canvas?, brushName: String) {
        self.vertices = verts
        self.canvas = canvas
        self.brushName = brushName
        self.isFreeHand = true
        self.start = CGPoint()
        
    }
    
    public init(from decoder: Decoder) throws {
        var container = try? decoder.unkeyedContainer()
        
        self.vertices = try container?.decodeIfPresent([Vertex].self) ?? []
        self.brushName = try container?.decodeIfPresent(String.self) ?? "defaultBrush"
        self.isFreeHand = try container?.decodeIfPresent(Bool.self) ?? true
        self.start = try container?.decodeIfPresent(CGPoint.self) ?? .zero
    }
    
    
    public func copy() -> Element {
        var e = Element(self.vertices, canvas: self.canvas, brushName: self.brushName)
        e.start = self.start
        e.isFreeHand = self.isFreeHand
        return e
    }
    
    
    
    // MARK: Functions
    
    /** Starts a new path using this element. */
    internal mutating func startPath(point: CGPoint, isFreeHand: Bool = true) {
        guard let canvas = canvas else { return }
        self.brushName = canvas.currentBrush.name
        guard let brush = canvas.getBrush(
            withName: self.brushName,
            with: [
                // TODO: Brush size is not working
                BrushOption.Size: canvas.currentBrush.size,
                BrushOption.Color: canvas.currentBrush.color,
                BrushOption.Opacity: canvas.currentBrush.opacity,
                BrushOption.TextureName: canvas.currentBrush.textureName,
                BrushOption.IsEraser: canvas.currentBrush.isEraser,
            ]
        ) else { return }
        
        // Configure the element.
        self.start = point
        self.isFreeHand = isFreeHand
        
        // Add the first vertex.
        let vert = Vertex(
            position: point,
            size: 0,
            color: brush.color.withAlphaComponent(brush.opacity),
            rotation: 0
        )
        self.vertices = [vert]
        BezierGenerator.startPath(with: point)
    }
    
    /** Finishes this element so that no more quads can be added to it without starting an
     entirely new element (i.e. lifting the stylus and drawing a new curve). */
    internal mutating func closePath() {
        vertices = []
        BezierGenerator.closePath()
    }
    
    /** Ends the last quad that exists on this element. */
    internal mutating func endPencil(at point: CGPoint) {
        guard let canvas = canvas else { return }
        guard let brush = canvas.getBrush(
            withName: self.brushName,
            with: [
                // TODO: Brush size is not working
                BrushOption.Size: canvas.currentBrush.size,
                BrushOption.Color: canvas.currentBrush.color,
                BrushOption.Opacity: canvas.currentBrush.opacity,
                BrushOption.TextureName: canvas.currentBrush.textureName,
                BrushOption.IsEraser: canvas.currentBrush.isEraser,
            ]
        ) else { return }
        
        // Generate the vertices to the next point.
        let verts = BezierGenerator.add(point: point).map {
            Vertex(
                position: $0,
                size: brush.size * canvas.force,
                color: brush.color.withAlphaComponent(brush.opacity),
                rotation: point.angel(to: self.start)
            )
        }
        vertices.append(contentsOf: verts)
    }
    
    /**Ends the curve as a particular tool.  */
    internal mutating func end(at point: CGPoint, as tool: CanvasTool) {
        guard let canvas = canvas else { return }
        guard let brush = canvas.getBrush(
            withName: self.brushName,
            with: [
                BrushOption.Size: canvas.currentBrush.size,
                BrushOption.Color: canvas.currentBrush.color,
                BrushOption.Opacity: canvas.currentBrush.opacity,
                BrushOption.TextureName: canvas.currentBrush.textureName,
                BrushOption.IsEraser: canvas.currentBrush.isEraser,
            ]
        ) else { return }

        // End and display the quad as the current tool where you currently drag.
        switch tool {
            case .rectangle:
                let verts = endRectangle(start: self.start, end: point, brush: brush)
                self.vertices = verts
                break
            case .line:
                let verts = endLine(start: self.start, end: point, brush: brush)
                self.vertices = verts
                break
            case .ellipse:
                let verts = endEllipse(start: self.start, end: point, brush: brush)
                self.vertices = verts
                break
            default:
                break
        }
    }
    
    
    // MARK: Rendering
    
    /** Rebuilds the buffer. */
    internal mutating func rebuildBuffer() {
        guard let canvas = canvas else { return }
        
        if vertices.count > 0 {
            buffer = canvas.device!.makeBuffer(
                bytes: vertices,
                length: vertices.count * MemoryLayout<Vertex>.stride,
                options: []
            )
        }
    }
    
    /** Renders the element to the screen. */
    internal mutating func render(canvas: Canvas, buffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder) {
        guard vertices.count > 0 else { return }
        guard let vBuff = self.buffer else { return }
        guard let brush = canvas.getBrush(withName: self.brushName) else { return }
        
        // Set the properties on the encoder for this element and the brush it uses specifically.
        encoder.setRenderPipelineState(brush.pipeline)
        encoder.setVertexBuffer(vBuff, offset: 0, index: 0)
        
        if let texName = brush.textureName, let txr = canvas.getTexture(withName: texName) {
            encoder.setFragmentTexture(txr, index: 0)
        }
        encoder.setFragmentSamplerState(canvas.sampleState, index: 0)
        
        // Draw primitives.
        let count = vBuff.length / MemoryLayout<Vertex>.stride
        encoder.drawPrimitives(type: isFreeHand == true ? .point : .triangle, vertexStart: 0, vertexCount: count)
    }
    
    
    // MARK: Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(vertices)
        try container.encode(brushName)
        try container.encode(start)
        try container.encode(isFreeHand)
    }
    
}
