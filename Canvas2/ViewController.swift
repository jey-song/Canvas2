//
//  ViewController.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/7/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import UIKit

public extension UIDevice {
    static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}

class ViewController: UIViewController, CanvasEvents {
    
    let colors: [UIColor] = [.black, .green, .red, .blue, .purple, .orange, .brown, .cyan]
    lazy var tools: [CanvasTool] = [
        CanvasTool.pencil,
        CanvasTool.rectangle,
        CanvasTool.line,
        CanvasTool.ellipse,
        CanvasTool.eraser
    ]
    var currentBrush: Int = 0
    
    lazy var canvas: Canvas = {
        let a = Canvas()
        a.translatesAutoresizingMaskIntoConstraints = false
        a.backgroundColor = .white
        a.forceEnabled = UIDevice.isSimulator() ? false : true
        a.stylusOnly = UIDevice.isSimulator() ? false : true
        a.currentBrush.size = 20
        a.maximumForce = 1.0
        a.addLayer(at: 0)
        
        return a
    }()
    
    let colorButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Random Color", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let toolButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Random Tool", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(changeTool), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let addLayerButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Add Layer Below", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(addLayer), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let addLayerButton2: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Add Layer Above", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(addLayerAbove), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let switchLayerButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Next Layer", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(cycleLayer), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let removeLayerButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Remove Current Layer", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(removeCurrentLayer), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let moveLayerButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Move Back Layer to Front", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(moveBackLayerToFront), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let brushButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Change Brush", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(changeBrush), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let toggleLockButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Toggle Lock Layer 0", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(toggleLock), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let toggleHideButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Toggle Hide Layer 0", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(toggleHide), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let undoButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Undo", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(undo), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let redoButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Redo", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(redo), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let exportButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Export", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(export), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    let clearButton: UIButton = {
        let a = UIButton(type: UIButton.ButtonType.custom)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.setTitle("Clear", for: .normal)
        a.setTitleColor(.black, for: .normal)
        a.setTitleColor(.darkGray, for: .highlighted)
        a.addTarget(self, action: #selector(clear), for: .touchUpInside)
        a.backgroundColor = .gray
        a.layer.cornerRadius = 8
        a.layer.shadowColor = UIColor.black.cgColor
        a.layer.shadowOffset = CGSize(width: 0, height: 2)
        a.layer.shadowRadius = 20
        a.layer.shadowOpacity = Float(0.5)
        
        return a
    }()
    
    
    // MARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkGray
        self.setupCanvas()
        
        // Setup the view.
        self.view.addSubview(canvas)
        self.view.addSubview(toolButton)
        self.view.addSubview(colorButton)
        self.view.addSubview(addLayerButton)
        self.view.addSubview(addLayerButton2)
        self.view.addSubview(switchLayerButton)
        self.view.addSubview(removeLayerButton)
        self.view.addSubview(moveLayerButton)
        self.view.addSubview(brushButton)
        self.view.addSubview(toggleLockButton)
        self.view.addSubview(toggleHideButton)
        self.view.addSubview(undoButton)
        self.view.addSubview(redoButton)
        self.view.addSubview(exportButton)
        self.view.addSubview(clearButton)
        
        canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        canvas.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7).isActive = true
        
        toolButton.topAnchor.constraint(equalTo: canvas.bottomAnchor, constant: 10).isActive = true
        toolButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        toolButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        toolButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        colorButton.topAnchor.constraint(equalTo: canvas.bottomAnchor, constant: 10).isActive = true
        colorButton.leadingAnchor.constraint(equalTo: toolButton.trailingAnchor, constant: 10).isActive = true
        colorButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        colorButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addLayerButton.topAnchor.constraint(equalTo: canvas.bottomAnchor, constant: 10).isActive = true
        addLayerButton.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 10).isActive = true
        addLayerButton.widthAnchor.constraint(equalToConstant: 170).isActive = true
        addLayerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addLayerButton2.topAnchor.constraint(equalTo: canvas.bottomAnchor, constant: 10).isActive = true
        addLayerButton2.leadingAnchor.constraint(equalTo: addLayerButton.trailingAnchor, constant: 10).isActive = true
        addLayerButton2.widthAnchor.constraint(equalToConstant: 170).isActive = true
        addLayerButton2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        switchLayerButton.topAnchor.constraint(equalTo: canvas.bottomAnchor, constant: 10).isActive = true
        switchLayerButton.leadingAnchor.constraint(equalTo: addLayerButton2.trailingAnchor, constant: 10).isActive = true
        switchLayerButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        switchLayerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        removeLayerButton.topAnchor.constraint(equalTo: toolButton.bottomAnchor, constant: 10).isActive = true
        removeLayerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        removeLayerButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        removeLayerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        moveLayerButton.topAnchor.constraint(equalTo: toolButton.bottomAnchor, constant: 10).isActive = true
        moveLayerButton.leadingAnchor.constraint(equalTo: removeLayerButton.trailingAnchor, constant: 10).isActive = true
        moveLayerButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        moveLayerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        brushButton.topAnchor.constraint(equalTo: toolButton.bottomAnchor, constant: 10).isActive = true
        brushButton.leadingAnchor.constraint(equalTo: moveLayerButton.trailingAnchor, constant: 10).isActive = true
        brushButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        brushButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        toggleLockButton.topAnchor.constraint(equalTo: toolButton.bottomAnchor, constant: 10).isActive = true
        toggleLockButton.leadingAnchor.constraint(equalTo: brushButton.trailingAnchor, constant: 10).isActive = true
        toggleLockButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        toggleLockButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        toggleHideButton.topAnchor.constraint(equalTo: removeLayerButton.bottomAnchor, constant: 10).isActive = true
        toggleHideButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        toggleHideButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        toggleHideButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        undoButton.topAnchor.constraint(equalTo: removeLayerButton.bottomAnchor, constant: 10).isActive = true
        undoButton.leadingAnchor.constraint(equalTo: toggleHideButton.trailingAnchor, constant: 10).isActive = true
        undoButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        undoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        redoButton.topAnchor.constraint(equalTo: removeLayerButton.bottomAnchor, constant: 10).isActive = true
        redoButton.leadingAnchor.constraint(equalTo: undoButton.trailingAnchor, constant: 10).isActive = true
        redoButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        redoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        exportButton.topAnchor.constraint(equalTo: removeLayerButton.bottomAnchor, constant: 10).isActive = true
        exportButton.leadingAnchor.constraint(equalTo: redoButton.trailingAnchor, constant: 10).isActive = true
        exportButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        exportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        clearButton.topAnchor.constraint(equalTo: removeLayerButton.bottomAnchor, constant: 10).isActive = true
        clearButton.leadingAnchor.constraint(equalTo: exportButton.trailingAnchor, constant: 10).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    func setupCanvas() {
        canvas.canvasDelegate = self
        
        // Load some textures.
        if let img = UIImage(named: "Smudge.png") {
            canvas.addTexture(img, forName: "paintTexture")
            print("Added the paint texture!")
        }
        if let img = UIImage(named: "Splash.png") {
            canvas.addTexture(img, forName: "splashTexture")
            print("Added the splash texture!")
        }
        
        // Load a brush.
        let basicPaint: Brush = Brush(name: "basicPaintBrush", config: [
            BrushOption.Size: CGFloat(20),
            BrushOption.Color: UIColor.black,
            BrushOption.TextureName: "paintTexture"
        ])
        let shapeBrush: Brush = Brush(name: "shapeBrush", config: [
            BrushOption.Size: CGFloat(50),
            BrushOption.Color: UIColor.black.withAlphaComponent(0.2),
            BrushOption.TextureName: "splashTexture"
        ])
        canvas.addBrush(basicPaint)
        canvas.addBrush(shapeBrush)
        print("Added brushes!")
        
        // Set the current brush.
        canvas.changeBrush(to: "basicPaintBrush")
        
        // Gestures.
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
        canvas.addGestureRecognizer(pinch)
    }
    
    @objc func zoom(gesture: UIPinchGestureRecognizer) {
        let anchor = CGPoint(x: view.frame.width / canvas.frame.width, y: view.frame.height / canvas.frame.height)

        let initialScale = self.canvas.contentScaleFactor
        let totalScale = min(max(gesture.scale * initialScale, 0.125), 8)
        let scaling = totalScale/initialScale

        var transform = CGAffineTransform(translationX: anchor.x, y: anchor.y)
        transform = transform.scaledBy(x: scaling, y: scaling)
        transform = transform.translatedBy(x: -anchor.x, y: -anchor.y)

        self.canvas.transform = self.canvas.transform.concatenating(transform)
        gesture.scale = 1
    }

    
    // MARK: Functions
    
    /** Changes the color of the brush. */
    @objc func changeColor() {
        let rand = Int(arc4random_uniform(UInt32(colors.count)))
        if canvas.currentBrush.color == colors[rand] {
            return changeColor()
        }
        canvas.currentBrush.color = colors[rand]
        print("Changed color to \(colors[rand])")
    }
    
    /** Changes to a random shape. */
    @objc func changeTool() {
        let rand = Int(arc4random_uniform(UInt32(tools.count)))
        canvas.changeTool(to: tools[rand])
    }
    
    /** Adds a layer below the current one. */
    @objc func addLayer() {
        canvas.addLayer(at: canvas.currentLayer)
        print("Created layer below. There are now \(canvas.canvasLayers.count) layers")
    }
    @objc func addLayerAbove() {
        canvas.addLayer(at: canvas.currentLayer + 1)
        print("Created layer above. There are now \(canvas.canvasLayers.count) layers")
    }
    
    /** Cycles to the next layer. */
    @objc func cycleLayer() {
        if canvas.currentLayer == canvas.canvasLayers.count - 1 {
            canvas.switchLayer(to: 0)
        } else {
            canvas.switchLayer(to: canvas.currentLayer + 1)
        }
        
        print("Switched to layer \(canvas.currentLayer)")
    }
    
    @objc func removeCurrentLayer() {
        canvas.removeLayer(at: canvas.currentLayer)
        print("Removed current layer. There are now \(canvas.canvasLayers.count) layers")
    }
    
    @objc func moveBackLayerToFront() {
        canvas.moveLayer(from: 0, to: 1)
        print("Moved layer 0 to layer 1. What was layer 0 is now at the front.")
    }
    
    @objc func changeBrush() {
        currentBrush = currentBrush == 0 ? 1 : 0
        
        if self.currentBrush == 0 {
            canvas.changeBrush(to: "basicPaintBrush")
        } else if currentBrush == 1 {
            canvas.changeBrush(to: "shapeBrush")
        }
    }
    
    @objc func toggleLock() {
        if canvas.canvasLayers[canvas.currentLayer].isLocked == false {
            canvas.lock(layer: 0)
        } else {
            canvas.unlock(layer: 0)
        }
    }
    
    @objc func toggleHide() {
        if canvas.canvasLayers[canvas.currentLayer].isHidden == false {
            canvas.hide(layer: 0)
        } else {
            canvas.show(layer: 0)
        }
    }
    
    @objc func undo() {
        canvas.undo()
    }
    
    @objc func redo() {
        canvas.redo()
    }
    
    @objc func export() {
        guard let img = canvas.export() else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
    
    @objc func clear() {
        canvas.clear()
    }
    
    
    
    // MARK: CanvasEvents
    
    func isDrawing(element: Element, on canvas: Canvas) {
        print("---> isDrawing ")
    }
    
    func stoppedDrawing(element: Element, on canvas: Canvas) {
        
    }
    
    func didChangeBrush(to brush: Brush) {
        print("---> Changed Brush: \(brush.name)")
    }
    
    func didChangeTool(to tool: CanvasTool) {
        print("---> Changed Tool: \(tool)")
    }
    
    func didUndo(on canvas: Canvas) {
        
    }
    
    func didRedo(on canvas: Canvas) {
        
    }
    
    func didClear(canvas: Canvas) {
        
    }
    
    func didClear(layer at: Int, on canvas: Canvas) {
        
    }
    
    func didAddLayer(at index: Int, to canvas: Canvas) {
        
    }
    
    func didRemoveLayer(at index: Int, from canvas: Canvas) {
        
    }
    
    func didMoveLayer(from startIndex: Int, to destIndex: Int, on canvas: Canvas) {
        
    }
    
    func didSwitchLayer(from oldLayer: Int, to newLayer: Int, on canvas: Canvas) {
        
    }
}

