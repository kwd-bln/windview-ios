//
//  SondeData+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import CoreGraphics

extension SondeData {
    /// SondeDataItemの角度を求める
    ///
    /// - Parameters:
    ///     - item: SondeDataItem
    ///     - useTN: 真北を使うか
    /// - Returns: useTNで指定した角度
    func degree(with item: SondeDataItem, useTN: Bool = false) -> CGFloat {
        if useTN {
            return item.windheading
        } else {
            return item.windheading - self.magDeclination
        }
    }
}
