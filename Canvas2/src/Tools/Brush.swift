//
//  Brush.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/15/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit


/** A single configuration option for a brush. */
public enum BrushOption {
    /** A CGFloat value for the size of the brush. */
    case Size
    
    /** A UIColor value for the color of the brush. */
    case Color
    
    /** A CGFloat value for the opacity of the brush. */
    case Opacity
    
    /** An optional String value for the name of the texture to use on this brush.*/
    case TextureName
    
    /** A Bool value for whether or not this brush should be used as an eraser. */
    case IsEraser
}

public let defaultConfig: [BrushOption : Any?] = {
    return [
        BrushOption.Size: CGFloat(10.0),
        BrushOption.Color: UIColor.black,
        BrushOption.Opacity: CGFloat(1.0),
        BrushOption.TextureName: nil,
        BrushOption.IsEraser: false,
    ]
}()


/** A customizable brush that determines how curves drawn on the canvas will look. */
public struct Brush: Codable {
    
    // MARK: Variables
    
    internal var canvas: Canvas?
    
    internal var name: String
    
    public var size: CGFloat
    
    public var color: UIColor
    
    public var opacity: CGFloat
    
    internal var textureName: String?
    
    internal var isEraser: Bool
    
    internal var pipeline: MTLRenderPipelineState!
    
    
    
    
    
    
    
    // MARK: Initialization
    
    public init(canvas: Canvas?, name: String, config: [BrushOption : Any?] = defaultConfig) {
        self.canvas = canvas
        self.name = name
        
        let size = config[BrushOption.Size] as? CGFloat ?? defaultConfig[BrushOption.Size] as! CGFloat
        let color = config[BrushOption.Color] as? UIColor ?? defaultConfig[BrushOption.Color] as! UIColor
        let opacity = config[BrushOption.Opacity] as? CGFloat ?? defaultConfig[BrushOption.Opacity] as! CGFloat
        let textureName = config[BrushOption.TextureName] as? String ?? defaultConfig[BrushOption.TextureName] as? String
        let isEraser = config[BrushOption.IsEraser] as? Bool ?? defaultConfig[BrushOption.IsEraser] as! Bool
        
        self.size = size
        self.color = color
        self.opacity = opacity
        self.textureName = textureName
        self.isEraser = isEraser
    }
    
    public init(from decoder: Decoder) throws {
        var container = try? decoder.unkeyedContainer()
        
        let decArr = (try container?.decodeIfPresent(String.self) ?? "").split(separator: "*")
        let nameString = String(decArr[0])
        let sizeString = String(decArr[1])
        let colorString = String(decArr[2]).split(separator: ",")
        let opacityString = String(decArr[3])
        let texNameString = String(decArr[4])
        let isEraserString = String(decArr[5])
        
        self.name = nameString
        self.size = CGFloat(truncating: NumberFormatter().number(from: sizeString) ?? 10.0)
        self.color = UIColor(
            red: CGFloat(truncating: NumberFormatter().number(from: String(colorString[0])) ?? 0.0),
            green: CGFloat(truncating: NumberFormatter().number(from: String(colorString[1])) ?? 0.0),
            blue: CGFloat(truncating: NumberFormatter().number(from: String(colorString[2])) ?? 0.0),
            alpha: CGFloat(truncating: NumberFormatter().number(from: String(colorString[3])) ?? 0.0)
        )
        self.opacity = CGFloat(truncating: NumberFormatter().number(from: opacityString) ?? 1.0)
        self.textureName = texNameString == "" ? nil : texNameString
        self.isEraser = isEraserString == "true" ? true : false
    }
    
    
    
    
    // MARK: Functions
    
    /** Sets up the pipeline for this brush. */
    internal mutating func setupPipeline() {
        guard let device = canvas?.device else { return }
        guard let lib = getLibrary(device: device) else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        self.pipeline = buildRenderPipeline(device: device, vertProg: vertProg, fragProg: fragProg)
    }
    
    /** Makes a copy of this brush. */
    func copy() -> Brush {
        let config: [BrushOption : Any?] = [
            BrushOption.Size: self.size,
            BrushOption.Color: self.color,
            BrushOption.Opacity: self.opacity,
            BrushOption.TextureName: self.textureName,
            BrushOption.IsEraser: self.isEraser,
        ]
        var b: Brush = Brush(canvas: self.canvas, name: self.name, config: config)
        b.pipeline = self.pipeline
        return b
    }
    
    
    // MARK: Decoding
    
    /** Changes the brush to match the current options. */
    internal mutating func load(from config: [BrushOption : Any?]) -> Brush {
        let s = config[BrushOption.Size] as? CGFloat
        let color = config[BrushOption.Color] as? UIColor
        let opacity = config[BrushOption.Opacity] as? CGFloat
        let textureName = config[BrushOption.TextureName] as? String
        let isEraser = config[BrushOption.IsEraser] as? Bool
        
        var brush = copy()
        if s != nil { brush.size = s! }
        if color != nil { brush.color = color! }
        if opacity != nil { brush.opacity = opacity! }
        if textureName != nil { brush.textureName = textureName! }
        if isEraser != nil { brush.isEraser = isEraser! }
        return brush
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        let c = color.rgba
        
        let nameString = "\(name)"
        let sizeString = "\(size)"
        let colorString = "\(c.red),\(c.green),\(c.blue),\(c.alpha)"
        let opacityString = "\(opacity)"
        let texNameString = "\(textureName ?? "")"
        let isEraserString = "\(isEraser)"
        
        let encodeString = "\(nameString)*\(sizeString)*\(colorString)*\(opacityString)*\(texNameString)*\(isEraserString)"
        try container.encode(encodeString)
    }
    
}
