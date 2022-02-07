//
//  UIFont+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/07.
//

import Foundation
import UIKit

extension UIFont {
    enum borderStyle: String {
        case light = "HiraginoSans-W3"
        case bold = "HiraginoSans-W6"
        case extraBold = "HiraginoSans-W7"
    }
    
    static func hiraginoSans(style: borderStyle, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size)!
    }
}
