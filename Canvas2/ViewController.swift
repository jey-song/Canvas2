//
//  ViewController.swift
//  Canvas2
//
//  Created by Adeola Uthman on 11/7/19.
//  Copyright © 2019 Adeola Uthman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let canvas: Canvas = Canvas()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        
        canvas.testCanvas(name: "Adeola Uthman!!!")
    }


}

