//
//  UnitConverter.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/20.
//

import Foundation
import CoreGraphics

final class UnitConverter {
    static func meterToFt(_ value: CGFloat) -> CGFloat {
        value * 3.28084
    }
    
    static func mpsToKt(_ value: CGFloat) -> CGFloat {
        value * 1.9438
    }
    
    static func mpsTokmph(_ value: CGFloat) -> CGFloat {
        value * 3.6
    }
}
