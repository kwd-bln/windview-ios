//
//  UIBezierPath+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit

extension UIBezierPath {
    func addCircle(center: CGPoint, with radius: CGFloat) {
        addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
    }
}
