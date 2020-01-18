//
//  UIImage+Extensions.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/18/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    
    /** Returns the color information at a certain pixel. */
    subscript(_ point: CGPoint) -> UIColor? {
        guard let pixelData = self.cgImage?.dataProvider?.data else { return nil }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = Int((size.width * point.y + point.x) * 4.0 * scale * scale)
        let i = Array(0 ... 3).map { CGFloat(data[pixelInfo + $0]) / CGFloat(255) }
        return UIColor(red: i[0], green: i[1], blue: i[2], alpha: i[3])
    }
    
}
