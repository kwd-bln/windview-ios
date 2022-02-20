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
    
    init(from sondeData: SondeData, useTN: Bool) {
        self.magDeclination = sondeData.magDeclination
        self.speedPoints = sondeData.speedPoint(useTN: useTN)
    }
}

private extension SondeData {
    func speedPoint(useTN: Bool = true) -> [(altitude: CGFloat, speedPoint: CGPoint)] {
        values.map { item in
            let degree: CGFloat = degree(with: item, useTN: useTN, isFrom: false).toRadian
            let vx = item.windspeed * sin(degree)
            let vy = -item.windspeed * cos(degree)
            let v = CGPoint(x: vx, y: vy)
            return (item.height, v)
        }
    }
}
