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
    public func exportLayerElements(at index: Int) -> Data? {
        guard index >= 0 && index < canvasLayers.count else { return nil }
        
        do {
            let layer = canvasLayers[index]
            let data: Data = try JSONEncoder().encode(layer.elements)
            return data
        } catch {
            return nil
        }
    }
    
    /** Sets layer data given properly formatted element data. */
    public func load(drawings data: Data, onto layer: Int) -> Bool {
        guard layer >= 0 && layer < canvasLayers.count else { return false }
        
        guard let dec = try? JSONDecoder().decode([Element].self, from: data) else { return false }
        canvasLayers[layer].elements = dec
        rebuildBuffer()
        
        return true
    }
    
    /** Loads layer data onto the canvas, then reloads the canvas. */
    public func load(from layersData: Data) -> Bool {
        guard let layers = try? JSONDecoder().decode([Layer].self, from: layersData) else {
            return false
        }
        
        canvasLayers.removeAll()
        currentLayer = 0
        mainTexture = nil
        mainBuffer = nil
        
        canvasLayers = layers
        currentLayer = layers.count > 0 ? 0 : -1
        rebuildBuffer()
        return true
    }
    
    /** Sets the layers based on whatever you pass in.. */
    public func set(layers: [Layer]) -> Bool {
        canvasLayers.removeAll()
        currentLayer = 0
        mainTexture = nil
        mainBuffer = nil
        
        canvasLayers = layers
        currentLayer = layers.count > 0 ? 0 : -1
        rebuildBuffer()
        return true
    }
    
}
