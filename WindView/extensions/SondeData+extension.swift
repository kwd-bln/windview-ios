//
//  SondeData+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import CoreGraphics

extension SondeData {
    /// SondeDataItemの角度を求める
    ///
    /// - Parameters:
    ///     - item: SondeDataItem
    ///     - useTN: 真北を使うか
    /// - Returns: useTNで指定した角度
    func degree(with item: SondeDataItem, useTN: Bool = false) -> CGFloat {
        if useTN {
            return item.windheading
        } else {
            return item.windheading - self.magDeclination
        }
    }
    
    var locationText: String {
        guard let addressComponents = location?.addressComponents else { return "" }
        let country = addressComponents.first(where: { $0.types.first == "country" })
        let adminAreaLv1 = addressComponents.first(where: { $0.types.first == "administrative_area_level_1" })
        let locality = addressComponents.first(where: { $0.types.first == "locality" })
        
        let countryText = country?.shortName ?? ""
        let adminAreaText = adminAreaLv1?.shortName ?? ""
        let localityText = locality?.longName ?? ""
        
        return "\(localityText) \(adminAreaText), \(countryText)"
    }
}
