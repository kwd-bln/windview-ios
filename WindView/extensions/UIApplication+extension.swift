//
//  UIApplication+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/23.
//

import UIKit

extension UIApplication {
    func openGoogleMap(lat: CGFloat, lng: CGFloat) {
        let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat)%2C\(lng)")!
        if canOpenURL(url) {
            open(url, options: [:], completionHandler: nil)
        }
    }
}
