//
//  Canvas+Layers.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

/** Extension that handles managing canvas layers. */
public extension Canvas {
    
    /** Adds a layer to the canvas. */
    func addLayer(at index: Int) {
        // Adding a layer does not require a rebuild of the buffer
        // because that will happen when the user draws again.
        if self.canvasLayers.count == 0 {
            self.canvasLayers.append(Layer())
            self.currentLayer = 0
            return
        }
        self.canvasLayers.insert(Layer(), at: index)
    }
    
    
    /** Deletes a layer from the canvas. */
    func removeLayer(at index: Int) {
        guard index >= 0 && index <= self.canvasLayers.count else { return }
        
        let oldLayer = self.canvasLayers[index]
        self.canvasLayers.remove(at: index)
        
        // Make sure the current layer variable doesn't
        // exceed the shortened length of the array.
        if self.currentLayer >= self.canvasLayers.count {
            self.currentLayer = self.canvasLayers.count
        }
        if self.canvasLayers.count == 0 {
            self.currentLayer = -1
        }
        
        // Rebuild the buffer. Start by finding the offset of the layer
        // you just removed.
        let oldLength = oldLayer.vertices.count
        var offset: Int = 0
        for i in 0..<index {
            offset += self.canvasLayers[i].vertices.count
        }
        
        // Now create a range which represents all the vertices that
        // existed on that layer. Use that range to remove those vertices
        // from the main vertex array.
        let start = offset
        let end = offset + oldLength
        let range = Range<Int>(uncheckedBounds: (lower: start, upper: end))
        totalVertices.removeSubrange(range)
        
        // Remake the main buffer.
        let totalLength = totalVertices.count * MemoryLayout<Vertex>.stride
        if totalLength == 0 {
            mainBuffer = nil
        } else {
            mainBuffer = dev.makeBuffer(bytes: totalVertices, length: totalLength, options: [])
        }
    }
    
    
    /** Moves the layer at the specified index to a different position on the canvas. */
    func moveLayer(from startIndex: Int, to destIndex: Int) {
        guard startIndex >= 0 && startIndex < self.canvasLayers.count else { return }
        guard destIndex >= 0 && destIndex < self.canvasLayers.count else { return }
        
        // First, get a reference to the layer that you are trying to move.
        let moveLayer = self.canvasLayers[startIndex]
        
        // Now, get a range for the vertices corresponding to that layer in
        // the total vertices array.
        let oldLength = moveLayer.vertices.count
        var offset: Int = 0
        for i in 0..<startIndex {
            offset += self.canvasLayers[i].vertices.count
        }
        let start = offset
        let end = offset + oldLength
        let moveRange = Range<Int>(uncheckedBounds: (lower: start, upper: end))
        let verticesToMove = totalVertices[start..<end]
        
        // Once you have the vertices that you want to move, you can remove them
        // from where they used to be in the total array.
        self.canvasLayers.remove(at: startIndex)
        self.canvasLayers.insert(moveLayer, at: destIndex)
        totalVertices.removeSubrange(moveRange)
        
        // Now you need a new index for where to insert it. This is because the
        // removal that is done just above causes the length of the array to change.
        var destOffset: Int = 0
        for i in 0..<destIndex {
            destOffset += self.canvasLayers[i].vertices.count
        }
        let destStart = destOffset
        totalVertices.insert(contentsOf: verticesToMove, at: destStart)
        
        // Remake the main buffer.
        let totalLength = totalVertices.count * MemoryLayout<Vertex>.stride
        if totalLength == 0 {
            mainBuffer = nil
        } else {
            mainBuffer = dev.makeBuffer(bytes: totalVertices, length: totalLength, options: [])
        }
    }
    
}
