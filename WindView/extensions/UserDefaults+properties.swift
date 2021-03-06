//
//  File.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/16.
//

import Foundation

extension UserDefaults {
    private enum Key: String {
        case selectedDate
        case isTrueNorth
        case chartDisplayDuration
        case speedUnit
        case altUnit
    }
    
    private subscript<T: Any>(key: Key) -> T? {
        get { object(forKey: key.rawValue) as? T }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    var selectedDate: Date? {
        get { load(key: Key.selectedDate.rawValue) }
        set { set(newValue, forKey: Key.selectedDate.rawValue) }
    }
    
    /// 真北かどうか
    var isTrueNorth: Bool {
        get { bool(forKey: Key.isTrueNorth.rawValue) }
        set { set(newValue, forKey: Key.isTrueNorth.rawValue)}
    }
    
    /// データ表示期間
    var chartDisplayDuration: Int {
        get {
            let int = integer(forKey: Key.chartDisplayDuration.rawValue)
            if int == 0 {
                UserDefaults.standard.chartDisplayDuration = 6
                return 6
            } else {
                return int
            }
        }
        set { set(newValue, forKey: Key.chartDisplayDuration.rawValue) }
    }
    
    /// speedの単位
    var speedUnit: SpeedUnit {
        get {
            let speedStr = string(forKey: Key.speedUnit.rawValue) ?? ""
            return SpeedUnit(rawValue: speedStr) ?? .mps
        }
        set {
            set(newValue.rawValue, forKey: Key.speedUnit.rawValue)
        }
    }
    
    /// speedの単位
    var altUnit: AltUnit {
        get {
            let altStr = string(forKey: Key.altUnit.rawValue) ?? ""
            return AltUnit(rawValue: altStr) ?? .m
        }
        set {
            set(newValue.rawValue, forKey: Key.altUnit.rawValue)
        }
    }
    
    private func load(key: String) -> Date? {
        let value = UserDefaults.standard.object(forKey: key)
        guard let date = value as? Date else {
            return nil
        }
        return date
    }
}
