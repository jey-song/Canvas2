//
//  Canvas.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/7/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/** The global Metal device. */
var dev: MTLDevice!

/** A Metal-accelerated canvas for drawing and painting. */
public class Canvas: MTKView, MTKViewDelegate {
    
    // MARK: Variables

    // ---> Internal
    
    internal var pipeline: MTLRenderPipelineState!
    internal var commands: MTLCommandQueue!
    
    internal var canvasLayers: [Layer]
        
    internal var currentDrawingCurve: [Quad]
    internal var nextQuad: Quad?
    internal var lastQuad: Quad?
    
    internal var force: CGFloat
    internal var textures: [String : MTLTexture]
    internal var brushes: [String : Brush]
    
    
    // ---> Overrides
    
    public override var bounds: CGRect {
        didSet {
            self.redraw()
        }
    }
    
    
    // ---> Public
    
    /** The brush that determines the styling of the next curve drawn on the canvas. */
    public internal(set) var currentBrush: Brush
    
    /** The tool that is currently used to add objects to the canvas. */
    public var currentTool: Tool!
    
    /** Whether or not the canvas should respond to force as a way to draw curves. */
    public var forceEnabled: Bool
    
    /** The maximum force allowed on the canvas. */
    public var maximumForce: CGFloat {
        didSet {
            self.maximumForce = CGFloat(simd_clamp(Float(self.maximumForce), 0.0, 1.0))
        }
    }
    
    /** Only allow styluses such as the Apple Pencil to be used for drawing. */
    public var stylusOnly: Bool
    
    /** The color to use to clear the canvas, which also serves as the background color. */
    public var canvasColor: UIColor
    
    /** The index of the current layer. */
    public var currentLayer: Int
    
    
    // --> Static/Computed
    
    /** A very basic pencil tool for freehand drawing. */
    lazy var pencilTool: Pencil = {
        return Pencil(canvas: self)
    }()
    
    /** A basic tool for creating perfect rectangles. */
    lazy var rectangleTool: Rectangle = {
        return Rectangle(canvas: self)
    }()
    
    /** A basic line tool for drawing straight lines. */
    lazy var lineTool: Line = {
        return Line(canvas: self)
    }()
    
    /** A basic circle tool for drawing straight lines. */
    lazy var ellipseTool: Ellipse = {
        return Ellipse(canvas: self)
    }()
    
//    /** A simple eraser. */
//    static let eraserTool: Eraser = {
//        return Eraser()
//    }()
    
    
    
    
    // MARK: Initialization
    
    public init() {
        dev = MTLCreateSystemDefaultDevice()
        self.forceEnabled = true
        self.stylusOnly = false
        self.force = 1.0
        self.maximumForce = 1.0
        self.currentBrush = Brush(size: 10, color: .black)
        self.commands = dev!.makeCommandQueue()
        self.currentDrawingCurve = []
        self.canvasColor = UIColor.white
        self.canvasLayers = []
        self.currentLayer = -1
        self.textures = [:]
        self.brushes = [:]
        
        // Configure the metal view.
        super.init(frame: CGRect.zero, device: dev)
        self.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        self.framebufferOnly = false
        
        // Configure the pipeline.
        guard let device = dev else { return }
        guard let lib = device.makeDefaultLibrary() else { return }
        guard let vertProg = lib.makeFunction(name: "main_vertex") else { return }
        guard let fragProg = lib.makeFunction(name: "textured_fragment") else { return }
        
        self.pipeline = buildRenderPipeline(vertProg: vertProg, fragProg: fragProg)
        self.currentTool = self.pencilTool // Default tool
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: Functions
    
    // ---> Public
    
    /** Registers a new brush that can be used on this canvas. */
    public func addBrush(_ brush: Brush, forName name: String) {
        self.brushes[name] = brush
    }
    
    /** Returns the brush with the specified name. */
    public func getBrush(withName name: String) -> Brush? {
        return self.brushes[name] ?? nil
    }
    
    /** Tells the canvas to keep track of another texture, which can be used later on for different brush strokes. */
    public func addTexture(_ image: UIImage, forName name: String) {
        guard image.size.width * image.size.height > 0 else { return }
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: Int(image.size.width),
            height: Int(image.size.height),
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        let texture = dev.makeTexture(descriptor: textureDescriptor)
        self.textures[name] = texture
    }
    
    /** Returns the texture that has been registered on the canvas using a particular name. */
    public func getTexture(withName name: String) -> MTLTexture? {
        guard let texture = self.textures[name] else { return nil }
        return texture
    }
    
    /** Tells the canvas to start using a different brush to draw with, based on the registered name. */
    public func changeBrush(to name: String) {
        guard let brush = self.getBrush(withName: name) else { return }
        self.currentBrush = brush
    }
    
    
    
    
    // ---> Internal
    
    /** Updates the force property of the canvas. */
    internal func setForce(value: CGFloat) {
        if self.forceEnabled == true {
            self.force = min(value, self.maximumForce)
        } else {
            // use simulated force
            var length = CGPoint(x: 1, y: 1).distance(to: .zero)
            length = min(length, 5000)
            length = max(100, length)
            self.force = sqrt(1000 / length)
        }
    }

    /** Adds a new element onto the canvas from the current drawing path. */
    internal func finishElement() {
        // Make sure there is always at least one layer.
        guard self.canvasLayers.count > 0 else { return }
        guard self.currentLayer >= 0 && self.currentLayer < self.canvasLayers.count else { return }
        
        
    }
    
    /** Clears and updates the screen with the newest drawing data, layer movements, etc. */
    internal func redraw() {
        // If there is a current drawing stroke, draw that.
        if currentDrawingCurve.count > 0 {
            finishElement()
        }
        
    }
    
    /** Updates the drawable on the canvas's underlying MTKView. */
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        
    }
}
