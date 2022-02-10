//
//  CGPoint+extenstion.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import CoreGraphics

extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    static func * (left: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: left * right.x, y: left * right.y)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: right * left.x, y: right * left.y)
    }

    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }
    
    static func / (left: CGPoint, right: CGPoint) -> CGPoint {
      return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }
    
    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: right / left.x, y: right / left.y)
    }
    
    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }
    
    // 距離の2乗
    var sqrtDist: CGFloat {
        x * x + y * y
    }
}
