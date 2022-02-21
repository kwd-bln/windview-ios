//
//  SpeedChartViewData.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import CoreGraphics

struct SpeedChartViewData {
    let magDeclination: CGFloat
    let speedPoints: [(altitude: CGFloat, speedPoint: CGPoint)]
    
    init(from sondeData: SondeData, useTN: Bool, unit: SpeedUnit = .mps) {
        self.magDeclination = sondeData.magDeclination
        self.speedPoints = sondeData.speedPoint(useTN: useTN, unit: unit)
    }
}

private extension SondeData {
    func speedPoint(useTN: Bool = true, unit: SpeedUnit) -> [(altitude: CGFloat, speedPoint: CGPoint)] {
        values.map { item in
            let degree: CGFloat = degree(with: item, useTN: useTN, isFrom: false).toRadian
            let convertedWindSpeed = unit.converted(from: item.windspeed)
            let vx = convertedWindSpeed * sin(degree)
            let vy = -convertedWindSpeed * cos(degree)
            let v = CGPoint(x: vx, y: vy)
            return (item.height, v)
        }
    }
}
