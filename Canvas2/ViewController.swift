//
//  ViewController.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/7/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let colors: [UIColor] = [.black, .green, .red, .blue]
    
    var canvas: Canvas = {
        let a = Canvas()
        a.forceEnabled = false
        a.stylusOnly = false
        a.currentBrush.size = 10
        
        return a
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkGray
        
        // Setup the canvas view.
        canvas.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.width,
            height: self.view.frame.height - 200
        )
        self.view.addSubview(canvas)
        
        // Set a timer every 10 seconds to change the color.
        let timer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(changeColor),
            userInfo: nil,
            repeats: true
        )
        timer.fire()
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
}

