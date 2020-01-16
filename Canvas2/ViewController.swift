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

class ViewController: UIViewController {
    
    let colors: [UIColor] = [.black, .green, .red, .blue]
    let tools: [Tool] = [Canvas.pencilTool, Canvas.rectangleTool]
    
    var canvas: Canvas = {
        let a = Canvas()
        a.translatesAutoresizingMaskIntoConstraints = false
        a.forceEnabled = UIDevice.isSimulator() ? false : true
        a.stylusOnly = UIDevice.isSimulator() ? false : true
        a.currentBrush.size = 10
        a.maximumForce = 1.0
        
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkGray
        
        // Setup the canvas view.
        self.view.addSubview(canvas)
        self.view.addSubview(toolButton)
        self.view.addSubview(colorButton)
        
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
    }


    
    
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
        print("Changed tool to \(tools[rand])")
    }
}

