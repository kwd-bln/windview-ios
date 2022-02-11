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
    
    /// 指定した有効数字で丸める関数
    /// precisionは1以上にする必要があり、そうしないとエラーが出てしまう。
    func toPrecition(_ precision: Int) -> CGFloat {
        if precision < 1 {
            fatalError("precisionには1以上を設定する必要があります。")
        }
        // 基準の上限
        let upper = pow(10, CGFloat(precision))
        // 基準の下限
        let lower = pow(10, CGFloat(precision - 1))
        // 割られていった値
        var devided: CGFloat = self
        // 元に戻すために必要な値
        var toGoToOriginal: CGFloat = 1
        
        if self >= upper {
            while devided >= upper {
                devided *= 0.1
                toGoToOriginal *= 10
            }
            return devided.rounded() * toGoToOriginal
        } else if self < lower {
            while devided < lower {
                devided *= 10
                toGoToOriginal *= 0.1
            }
            return devided.rounded() * toGoToOriginal
        } else {
            return self.rounded()
        }
    }
}
