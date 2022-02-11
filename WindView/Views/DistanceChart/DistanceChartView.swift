//
//  DistanceChartView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit

final class DistanceChartView: UIView {
    static let radiusRatio: CGFloat = 0.32
    static let chartLayerTag: Int = 1111
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .Palette.main
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
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
    func drawChart(by sondeDataList: [SondeData], with scale: ChartSize, isTo: Bool) {
        let distanceDataList = sondeDataList.map { DistantChartViewData(from: $0) }
        let maxDistance = distanceDataList.map { $0.maxDistance }
        let maxDist = maxDistance.max() ?? 0
        // 単位となる距離
        let unitDistance = calculateUnitDist(by: maxDist, size: scale)
        
        // 目盛りを描画
        drawScales(unitDistance)
        
        let numOfData = distanceDataList.count
        distanceDataList.reversed().enumerated().forEach { index, distanceData in
            drawUnitDistChart(by: distanceData,
                              in: unitDistance,
                              isTo: true,
                              color: UIColor.number(index, max: numOfData))
        }
    }
    
    /// 単位距離を計算する
    func calculateUnitDist(by maxDist: CGFloat, size: ChartSize) -> CGFloat {
        let oneThirdOfMaxDist = ceil(maxDist * Self.radiusRatio * size.rawValue)
        let unitDistance = max(oneThirdOfMaxDist.toPrecition(2), 10)
        return unitDistance
    }
    
    /// 目盛りを描画
    func drawScales(_ unitDistance: CGFloat) {
        let unitVector: CGPoint = .init(x: 0, y: bounds.width * 0.5 * 0.32)
        
        let rounded = Int(unitDistance)
        
        for i in 1...3 {
            let textLayer = CATextLayer.createTextLayer("\(rounded * i)[m]")
            let size = textLayer.preferredFrameSize()
            textLayer.bounds = CGRect(origin: .zero, size: size)
            textLayer.frame.origin = CGFloat(i) * unitVector + bounds.mid - .init(x: 0, y: size.height)
            textLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(textLayer)
        }
    }
    
    /// 1つの`DistantChartViewData`を描画する
    func drawUnitDistChart(by distData: DistantChartViewData,
                           in unit: CGFloat,
                           isTo: Bool,
                           color: UIColor) {
        let halfWidth = bounds.width / 2
        
        // distanceをrect中の長さに合わせるために掛ける定数
        let multiple = halfWidth / unit / 3
        // scaleされた点
        let scaledPoints = distData.distancePoints.map { $0 * multiple }
        
        // 線を描く処理
        let path = UIBezierPath()
        path.move(to: bounds.mid)
        scaledPoints.forEach { point in
            if point != .zero {
                path.addLine(to: point + bounds.mid)
            }
        }
        path.stroke()
        path.stroke()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        shapeLayer.lineWidth = 1
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = .none
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
        
        // 点を描く処理
        let circlePath = UIBezierPath()
        scaledPoints.forEach { point in
            let drawingPoint = point + bounds.mid
            circlePath.move(to: drawingPoint)
            circlePath.addCircle(center: drawingPoint, with: 2)
        }
        circlePath.stroke()
        
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        circleShapeLayer.lineWidth = 1
        circleShapeLayer.strokeColor = .none
        circleShapeLayer.fillColor = color.cgColor
        circleShapeLayer.path = circlePath.cgPath
        layer.addSublayer(circleShapeLayer)
    }
}

extension CATextLayer {
    static func createTextLayer(_ text: String,
                                color: UIColor = .gray,
                                fontSize: CGFloat = 10) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.foregroundColor = color.cgColor
        textLayer.fontSize = fontSize
        return textLayer
    }
}
