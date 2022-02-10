//
//  DistanceChartView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit

final class DistanceChartView: UIView {
    static let radiusRatio: CGFloat = 0.3
    static let chartLayerTag: Int = 1111
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .Palette.main
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawGrid(rect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 下地

private extension DistanceChartView {
    func drawGrid(_ rect: CGRect) {
        let path = UIBezierPath()

        path.lineWidth = 1
        let halfWidth = rect.width / 2
        let length30 = halfWidth * tan(CGFloat(30).toRadian)
        
        // 縦
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        // 横
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxY, y: rect.midY))
        
        // 斜めの線を描く
        path.move(to: CGPoint(x: rect.minX, y: rect.midY + length30))
        path.addLine(to: CGPoint(x: rect.maxY, y: rect.midY - length30))
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY - length30))
        path.addLine(to: CGPoint(x: rect.maxY, y: rect.midY + length30))
        
        path.move(to: CGPoint(x: rect.midX - length30, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + length30, y: rect.maxY))
        
        path.move(to: CGPoint(x: rect.midX + length30, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX - length30, y: rect.maxY))
        
        // 円を描く
        path.move(to: rect.mid)
        let radius = halfWidth * Self.radiusRatio
        path.addCircle(center: rect.mid, with: radius * 1)
        path.addCircle(center: rect.mid, with: radius * 2)
        path.addCircle(center: rect.mid, with: radius * 3)
        
        path.close()
        UIColor.gray.setStroke()
        path.stroke()
    }
}

// MARK: - draw chart

extension DistanceChartView {
    func drawChart(by sondeData: SondeData, with unit: CGFloat, isTo: Bool) {
        let halfWidth = bounds.width / 2
        
        let distancePoints = sondeData.distancePoints
        let squareDistances = distancePoints.map { $0.sqrtDist }
        let maxDist = sqrt(squareDistances.max() ?? 0)
        
        // unitDist: 単位の長さとなるDist
        let unitDist = maxDist * 0.96
        let ratio = halfWidth / unitDist
        
        let scaledDistancePoints = distancePoints.map { $0 * ratio }
        
        let path = UIBezierPath()
        path.move(to: bounds.mid)
        scaledDistancePoints.forEach { point in
            if point != .zero {
                path.addLine(to: point + bounds.mid)
            }
        }
        path.stroke()
        
        let circlePath = UIBezierPath()
        scaledDistancePoints.forEach { point in
            let drawingPoint = point + bounds.mid
            circlePath.move(to: drawingPoint)
            circlePath.addCircle(center: drawingPoint, with: 2)
        }
        circlePath.stroke()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        shapeLayer.lineWidth = 1
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.fillColor = .none
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
        
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        circleShapeLayer.lineWidth = 1
        circleShapeLayer.strokeColor = .none
        circleShapeLayer.fillColor = UIColor.blue.cgColor
        circleShapeLayer.path = circlePath.cgPath
        layer.addSublayer(circleShapeLayer)
    }
}

extension SondeData {
    var distancePoints: [CGPoint] {
        var currentPoint: CGPoint = .zero
        var points: [CGPoint] = [currentPoint]
        var prevHeight: CGFloat = 0
        
        values.forEach { item in
            // 前回測定分との高度の差
            let dH = item.height - prevHeight
            // 前回測定分との時間の差(s): 1分で100m上昇するという仮定のもと
            let dt = 60 * dH / 100
            
            let degree: CGFloat = degree(with: item).toRadian
            // y軸負の方向に向いたとき0度になることを注意する。
            let dx = item.windspeed * dt * sin(degree)
            let dy = -item.windspeed * dt * cos(degree)
            
            currentPoint += CGPoint(x: dx, y: dy)
            points.append(currentPoint)
            prevHeight = item.height
        }
        return points
    }
    
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
}
