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
    
    init(from sondeData: SondeData) {
        self.magDeclination = sondeData.magDeclination
        self.speedPoints = sondeData.speedPoint()
    }
}

private extension SondeData {
    func speedPoint() -> [(altitude: CGFloat, speedPoint: CGPoint)] {
        values.map { item in
            let degree: CGFloat = degree(with: item).toRadian
            let vx = item.windspeed * sin(degree)
            let vy = -item.windspeed * cos(degree)
            let v = CGPoint(x: vx, y: vy)
            return (item.height, v)
        }
    }
}
