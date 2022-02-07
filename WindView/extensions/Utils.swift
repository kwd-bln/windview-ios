//
//  Utils.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/07.
//

import UIKit

public enum Util {}

extension Util {
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
