//
//  Settings.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import FirebaseFirestore

enum ChartSize {
    case s
    case m
    case l
    case ll
}

struct DataSettings {
    // MARK: 全体的な設定
    /// 指定したデータから何時間分のデータを取得するか
    let useDataDuration: Int = 6
    let selectedDate: Timestamp
}
