//
//  DateUtil.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation

final class DateUtil {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    static func timeText(from date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
