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
    let useDataDuration: Int
    let selectedDate: Date?
    
    init(useDataDuration: Int = 0, selectedDate: Date? = nil) {
        self.useDataDuration = useDataDuration
        self.selectedDate = selectedDate
    }
}
