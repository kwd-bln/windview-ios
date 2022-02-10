//
//  CGFloat+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import CoreGraphics

extension CGFloat {
    /// 角度をラジアンに変換
    var toRadian: CGFloat {
        self * CGFloat.pi / 180
    }
}
