//
//  Settings.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import FirebaseFirestore
import CoreGraphics

enum ChartSize: CGFloat {
    case s = 0.6
    case m = 1.0
    case l = 1.5
    case ll = 2.0
    
    var next: ChartSize {
        switch self {
        case .s:
            return .m
        case .m:
            return .l
        case .l:
            return .ll
        case .ll:
            return .s
        }
    }
}

enum SpeedUnit: String, CaseIterable {
    case mps = "m/s"
    case kmph = "km/h"
    case kt = "kt"
    
    func converted(from mps: CGFloat) -> CGFloat {
        switch self {
        case .mps:
            return mps
        case .kmph:
            return UnitConverter.mpsTokmph(mps)
        case .kt:
            return UnitConverter.mpsToKt(mps)
        }
    }
}

enum AltUnit: String, CaseIterable {
    case m
    case ft
}

/// 使用するデータに関する設定
struct DateSettings {
    /// 指定したデータから何時間分のデータを取得するか
    let useDataDuration: Int
    let selectedDate: Date?
    
    init(useDataDuration: Int = 6,
         selectedDate: Date? = nil) {
        self.useDataDuration = useDataDuration
        self.selectedDate = selectedDate
    }
}

/// どんなデータを見せるかという設定
struct DisplayDataSetting {
    let isTrueNorth: Bool
    let speedUnit: SpeedUnit
    let altUnit: AltUnit
    
    init(isTrueNorth: Bool = true,
         speedUnit: SpeedUnit = .mps,
         altUnit: AltUnit = .m) {
        self.isTrueNorth = isTrueNorth
        self.speedUnit = speedUnit
        self.altUnit = altUnit
    }
}
