//
//  DistantChartViewData.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import CoreGraphics

struct DistantChartViewData {
    let measuredAt: Date
    let magDeclination: CGFloat
    let distancePoints: [CGPoint]
    
    init(from sondeData: SondeData, useTN: Bool) {
        self.measuredAt = sondeData.measuredAt.dateValue()
        self.magDeclination = sondeData.magDeclination
        self.distancePoints = sondeData.distancePoints(useTN: useTN)
    }
    
    var maxDistance: CGFloat {
        let squareDistances = distancePoints.map { $0.sqrtDist }
        return sqrt(squareDistances.max() ?? 0)
    }
}

private extension SondeData {
    func distancePoints(useTN: Bool) -> [CGPoint] {
        var currentPoint: CGPoint = .zero
        var points: [CGPoint] = [currentPoint]
        var prevHeight: CGFloat = 0
        
        values.forEach { item in
            // 前回測定分との高度の差
            let dH = item.height - prevHeight
            // 前回測定分との時間の差(s): 1分で100m上昇するという仮定のもと
            let dt = 60 * dH / 100
            
            let degree: CGFloat = degree(with: item, useTN: useTN, isFrom: false).toRadian
            // y軸負の方向に向いたとき0度になることを注意する。
            let dx = item.windspeed * dt * sin(degree)
            let dy = -item.windspeed * dt * cos(degree)
            
            currentPoint += CGPoint(x: dx, y: dy)
            points.append(currentPoint)
            prevHeight = item.height
        }
        return points
    }
}
