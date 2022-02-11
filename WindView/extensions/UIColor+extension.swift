//
//  UIColor+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/07.
//

import UIKit

extension UIColor {
    @propertyWrapper
    fileprivate struct Named {
        let name: String
        var wrappedValue: UIColor { UIColor(named: name)! }

        init(_ name: String) {
            self.name = name
        }
    }

    class Palette {
        @Named("main") static var main
        @Named("text") static var text
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}
