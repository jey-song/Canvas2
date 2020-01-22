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
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
}

class ViewController: UIViewController, CanvasEvents {
    
    let colors: [UIColor] = [.black, .green, .red, .blue, .purple, .orange, .brown, .cyan]
    lazy var tools: [Tool] = [
        self.canvas.pencilTool,
        self.canvas.rectangleTool,
        self.canvas.lineTool,
        self.canvas.ellipseTool
    ]
    var currentBrush: Int = 0
    
    lazy var canvas: Canvas = {
        let a = Canvas()
        a.translatesAutoresizingMaskIntoConstraints = false
        a.forceEnabled = UIDevice.isSimulator() ? false : true
        a.stylusOnly = UIDevice.isSimulator() ? false : true
        a.currentBrush.size = 20
        a.maximumForce = 1.0
        a.canvasColor = .white
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
    }

    func setupCanvas() {
        canvas.canvasDelegate = self
        
        // Load some textures.
        if let img = UIImage(named: "PencilTexture.jpg") {
            canvas.addTexture(img, forName: "pencilTexture")
            print("Added the pencil texture!")
        }
        if let img = UIImage(named: "InkTexture.jpg") {
            canvas.addTexture(img, forName: "inkTexture")
            print("Added the ink texture!")
        }
        if let img = UIImage(named: "Paper.jpg") {
            canvas.addTexture(img, forName: "paperTexture")
            print("Added the paper texture!")
        }
        
        // Load a brush.
        var basicPencil: Brush = Brush(name: "basicPencil", size: 10, color: .black)
        var basicInk: Brush = Brush(name: "basicInk", size: 10, color: .black)
        var basicBrush: Brush = Brush(name: "basicBrush", size: 10, color: .black)
        basicPencil.setTexture(name: "pencilTexture", canvas: canvas)
        basicInk.setTexture(name: "inkTexture", canvas: canvas)
        basicBrush.setTexture(name: "paperTexture", canvas: canvas)
        canvas.addBrush(basicPencil)
        canvas.addBrush(basicInk)
        canvas.addBrush(basicBrush)
        print("Added the basic pencil, basic ink, and basic paintbrush brushes!")
        
        // Set the current brush.
        canvas.changeBrush(to: "basicPencil")
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
        canvas.currentTool = tools[rand]
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
            canvas.currentLayer = 0
        } else {
            canvas.currentLayer += 1
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
        if currentBrush == 0 {
            currentBrush = 1
        } else if currentBrush == 1 {
            currentBrush = 2
        } else {
            currentBrush = 0
        }
        
        if self.currentBrush == 0 {
            canvas.changeBrush(to: "basicPencil")
        } else if currentBrush == 1{
            canvas.changeBrush(to: "basicInk")
        } else {
            canvas.changeBrush(to: "basicBrush")
        }
    }
    
    
    
    // MARK: CanvasEvents
    
    func isDrawing(element: Element, on canvas: Canvas) {
        print("---> Is drawing: \(element.length)")
    }
    
    func stoppedDrawing(element: Element, on canvas: Canvas) {
        print("---> Stopped drawing: \(element.length)")
    }
    
    func didChangeBrush(to brush: Brush) {
        print("---> Changed Brush: \(brush.name)")
    }
    
    func didChaneTool(to tool: Tool) {
        print("---> Changed Tool: \(tool)")
    }
    
    
    
}

