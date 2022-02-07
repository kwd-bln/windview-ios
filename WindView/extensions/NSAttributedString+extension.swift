//
//  NSAttributedString+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/07.
//

import UIKit

extension NSAttributedString {
    convenience init(string: String, font: UIFont, lineSpacing: CGFloat, alignment: NSTextAlignment) {
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        attributes.updateValue(paragraphStyle, forKey: .paragraphStyle)
        self.init(string: string, attributes: attributes)
    }
}
