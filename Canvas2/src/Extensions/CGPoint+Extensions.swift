//
//  CGPoint+Extensions.swift
//  Canvas2
//
//  Created by Adeola Uthman on 1/15/20.
//  Copyright © 2020 Adeola Uthman. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    func direction(to other: CGPoint) -> CGFloat {
        let dX = abs(other.x - self.x)
        let dY = abs(other.y - self.y)
        let t = atan(dY / dX)
        return t
    }
    
    func distance(to other: CGPoint) -> CGFloat {
        let p = pow(x - other.x, 2) + pow(y - other.y, 2)
        return sqrt(p)
    }
    
    static func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let p = pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)
        return sqrt(p)
    }
    
    private func norm() -> CGFloat {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    func normalize() -> CGPoint {
        let n = norm()
        let out = CGPoint(x: x / n, y: y / n)
        return out
    }
    
    func perpendicular(other: CGPoint) -> CGPoint {
        var diff = CGPoint(x: other.x - self.x, y: other.y - self.x)
        let length = hypot(diff.x, diff.y)
        diff.x /= length
        diff.y /= length
        let perp = CGPoint(x: -diff.y, y: diff.x)
        return perp
    }
    
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func *(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }
}
