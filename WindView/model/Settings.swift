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
}

enum AltUnit: String, CaseIterable {
    case m
    case ft
}

struct DataSettings {
    // MARK: 全体的な設定
    /// 指定したデータから何時間分のデータを取得するか
    let useDataDuration: Int
    let selectedDate: Date?
    let isTrueNorth: Bool
    let speedUnit: SpeedUnit
    let altUnit: AltUnit
    
    init(useDataDuration: Int = 6,
         selectedDate: Date? = nil,
         isTrueNorth: Bool = true,
         speedUnit: SpeedUnit = .mps,
         altUnit: AltUnit = .m) {
        self.useDataDuration = useDataDuration
        self.selectedDate = selectedDate
        self.isTrueNorth = isTrueNorth
        self.speedUnit = speedUnit
        self.altUnit = altUnit
    }
}
