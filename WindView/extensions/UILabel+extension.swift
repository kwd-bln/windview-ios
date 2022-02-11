//
//  UILabel+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import UIKit

extension UILabel {
    static func createDefaultLabel(_ text: String,
                                   color: UIColor = .Palette.text,
                                   font: UIFont = .systemFont(ofSize: 13)) -> UILabel {
        let label = UILabel()
        label.textColor = color
        label.font = font
        label.text = text
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }
}
