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
    }
    
    private subscript<T: Any>(key: Key) -> T? {
        get { object(forKey: key.rawValue) as? T }
        set { set(newValue, forKey: key.rawValue) }
    }
    
    var selectedDate: Date? {
        get { load(key: Key.selectedDate.rawValue) }
        set { set(newValue, forKey: Key.selectedDate.rawValue) }
    }
    
    private func load(key: String) -> Date? {
        let value = UserDefaults.standard.object(forKey: key)
        guard let date = value as? Date else {
            return nil
        }
        return date
    }
}
