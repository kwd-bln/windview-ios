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
    
    private var sondeDataList: [SondeData] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var size: ChartSize = .m {
        didSet {
            if size != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    private var isTo: Bool = true
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .Palette.main
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawGrid(rect, in: context)
        
        if sondeDataList.count > 0 {
            drawChart(rect, in: context, scale: size)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ sondeDataList: [SondeData]) {
        self.sondeDataList = sondeDataList
    }
    
    func set(_ chartSize: ChartSize) {
        self.size = chartSize
    }
}

// MARK: - draw chart

extension DistanceChartView {
    func drawChart(_ rect: CGRect, in context: CGContext, scale: ChartSize) {
        let distanceDataList = sondeDataList.map { DistantChartViewData(from: $0) }
        let maxDistance = distanceDataList.map { $0.maxDistance }
        let maxDist = maxDistance.max() ?? 0
        // 単位となる距離
        let unitDistance = calculateUnitDist(by: maxDist, size: scale)
        drawScales(rect, in: context, unitDistance: unitDistance)
        
        let numOfData = distanceDataList.count
        distanceDataList.reversed().enumerated().forEach { index, distanceData in
            drawUnitDistChart(rect,
                              in: context,
                              distData: distanceData,
                              unit: unitDistance,
                              color: UIColor.number(index, max: numOfData))
        }
    }
    
    /// 1つの`DistantChartViewData`を描画する
    func drawUnitDistChart(_ rect: CGRect,
                           in context: CGContext,
                           distData: DistantChartViewData,
                           unit: CGFloat,
                           color: UIColor) {
        let halfWidth = rect.width / 2
        
        // distanceをrect中の長さに合わせるために掛ける定数
        let multiple = halfWidth / unit * Self.radiusRatio
        // scaleされた点
        let scaledPoints = distData.distancePoints.map { $0 * multiple }
        
        // 線を描く処理
        context.move(to: rect.mid)
        scaledPoints.forEach { point in
            if point != .zero {
                context.addLine(to: point + rect.mid)
            }
        }
        context.setStrokeColor(color.cgColor)
        context.strokePath()
        
        // 点を描く処理
        scaledPoints.forEach { point in
            let drawingPoint = point + bounds.mid
            context.move(to: drawingPoint)
            context.addCircle(center: drawingPoint, with: 2)
        }
        
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}


// MARK: - 下地

private extension DistanceChartView {
    func drawGrid(_ rect: CGRect, in context: CGContext) {
        // 初期設定
        let halfWidth = rect.width / 2
        let length30 = halfWidth * tan(CGFloat(30).toRadian)
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.gray.cgColor)
        // 縦
        context.move(to: CGPoint(x: rect.midX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        // 横
        context.move(to: CGPoint(x: rect.minX, y: rect.midY))
        context.addLine(to: CGPoint(x: rect.maxY, y: rect.midY))
        
        // 斜めの線を描く
        context.move(to: CGPoint(x: rect.minX, y: rect.midY + length30))
        context.addLine(to: CGPoint(x: rect.maxY, y: rect.midY - length30))
        
        context.move(to: CGPoint(x: rect.minX, y: rect.midY - length30))
        context.addLine(to: CGPoint(x: rect.maxY, y: rect.midY + length30))
        
        context.move(to: CGPoint(x: rect.midX - length30, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.midX + length30, y: rect.maxY))
        
        context.move(to: CGPoint(x: rect.midX + length30, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.midX - length30, y: rect.maxY))
        
        // 円を描く
        context.move(to: rect.mid)
        let radius = halfWidth * Self.radiusRatio
        context.addCircle(center: rect.mid, with: radius * 1)
        context.addCircle(center: rect.mid, with: radius * 2)
        context.addCircle(center: rect.mid, with: radius * 3)
        
        context.strokePath()
    }
    
    /// 単位距離を計算する
    func calculateUnitDist(by maxDist: CGFloat, size: ChartSize) -> CGFloat {
        let oneThirdOfMaxDist = ceil(maxDist * Self.radiusRatio / size.rawValue)
        let unitDistance = max(oneThirdOfMaxDist.toPrecition(2), 10)
        return unitDistance
    }
    
    /// 目盛りを描画
    func drawScales(_ rect: CGRect, in context: CGContext, unitDistance: CGFloat) {
        let unitVector: CGPoint = .init(x: 0, y: rect.width * 0.5 * Self.radiusRatio)
        let rounded = Int(unitDistance)
        
        var attrs: [NSAttributedString.Key : Any] = [:]
        attrs[.foregroundColor] = UIColor.gray
        attrs[.font] = UIFont.systemFont(ofSize: 9)
        
        for i in 1...3 {
            let text = "\(rounded * i)[m]"
            let point: CGPoint = CGFloat(i) * unitVector + rect.mid
            let size = text.size(withAttributes: attrs)
            
            context.drawText(text, at: point - .init(x: -4, y: size.height * 0.6), align: .left, angleRadians: 0, attributes: attrs)
        }
    }
}
