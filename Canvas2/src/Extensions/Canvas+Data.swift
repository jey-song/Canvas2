//
//  Canvas+Data.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/31/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

extension Canvas {
    
    /** Exports the canvas as a UIImage. */
    public func export() -> UIImage? {
        guard let drawable = currentDrawable else { return nil }
        guard let cg = drawable.texture.toCGImage2() else { return nil }
        let image = UIImage(cgImage: cg)
        return image
    }
    
    /** Exports the canvas, all of its layers, brush data, etc. into codable data. */
    public func exportData() -> Data? {
        do {
            let data: Data = try JSONEncoder().encode(self)
            return data
        } catch {
            return nil
        }
    }
    
    /** Exports just the drawing layers so they can be reconstructed later on. */
    public func exportLayers() -> Data? {
        do {
            let layers: [Layer] = canvasLayers
            let data: Data = try JSONEncoder().encode(layers)
            return data
        } catch {
            return nil
        }
    }
    
    /** Exports a single layer's drawing data. */
    public func exportLayerDrawings(at index: Int) -> Data? {
        guard index >= 0 && index < canvasLayers.count else { return nil }
        
        do {
            let layer = canvasLayers[index]
            let data: Data = try JSONEncoder().encode(layer.elements)
            return data
        } catch {
            return nil
        }
    }
    
    /** Loads layer data onto the canvas, then reloads the canvas. */
    public func load(from layersData: Data) -> Bool {
        guard var layers = try? JSONDecoder().decode([Layer].self, from: layersData) else {
            return false
        }
        
        canvasLayers.removeAll()
        currentLayer = 0
        mainTexture = nil
        mainBuffer = nil
        
        // Make sure all canvas references are set.
        for i in 0..<layers.count {
            layers[i].canvas = self
            for j in 0..<layers[i].elements.count {
                layers[i].elements[j].canvas = self
                layers[i].elements[j].rebuildBuffer()
            }
        }
        
        canvasLayers = layers
        currentLayer = layers.count > 0 ? 0 : -1
        rebuildBuffer()
        setNeedsDisplay()
        return true
    }
    
    /** Sets the layers based on whatever you pass in.. */
    public func load(layers: [Layer]) -> Bool {
        canvasLayers.removeAll()
        currentLayer = 0
        mainTexture = nil
        mainBuffer = nil
        
        // Make sure all canvas references are set.
        var copy = layers
        for i in 0..<copy.count {
            copy[i].canvas = self
            for j in 0..<copy[i].elements.count {
                copy[i].elements[j].canvas = self
                copy[i].elements[j].rebuildBuffer()
            }
        }
        
        canvasLayers = copy
        currentLayer = copy.count > 0 ? 0 : -1
        rebuildBuffer()
        return true
    }
    
}
