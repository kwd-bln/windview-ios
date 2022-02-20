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
    func degree(with item: SondeDataItem, useTN: Bool = false, isFrom: Bool) -> CGFloat {
        let toDegree: CGFloat
        if useTN {
            toDegree = item.windheading
        } else {
            toDegree = item.windheading - self.magDeclination + 360
        }
        
        if !isFrom { return toDegree.truncatingRemainder(dividingBy: 360) }
        let fromDegree = (toDegree + 180).truncatingRemainder(dividingBy: 360)
        return fromDegree
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
