//
//  Strings+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/23.
//

import Foundation
import UIKit

extension String {
    func size(with font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font : font]
        return (self as NSString).size(withAttributes: attributes)
    }
}
