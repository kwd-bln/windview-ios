//
//  SpeedChartView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import UIKit
import simd
import SwiftUI

final class SpeedChartView: UIView {
    static let radiusRatio: CGFloat = 0.19
    
    private var sondeData: SondeData? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var isTo: Bool = true
    private var featuredIndex: Int? = nil
    /// 真北を使うかどうか
    private var useTN: Bool = true
    private var speedUnit: SpeedUnit = .mps
    
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
        drawGrid(in: context, with: rect)
        
        if let sondeData = sondeData {
            drawChart(rect, in: context, data: sondeData)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(sondeData: SondeData,
             isFrom: Bool,
             featuredIndex: Int?,
             useTN: Bool,
             speedUnit: SpeedUnit) {
        self.sondeData = sondeData
        self.isTo = !isFrom
        self.featuredIndex = featuredIndex
        self.useTN = useTN
        self.speedUnit = speedUnit
    }
}

// MARK: - draw chart

private extension SpeedChartView {
    func drawChart(_ rect: CGRect, in context: CGContext, data sondeData: SondeData) {
        // calculate max speed
        let maxSpeed = speedUnit.converted(from: sondeData.maxSpeed)
        
        // 単位となる速度
        let unitSpeed = calcUnitSpeed(maxSpeed)
        drawScales(rect, in: context, unitSpeed: unitSpeed)
        
        let speedViewData = SpeedChartViewData(from: sondeData, useTN: useTN, unit: speedUnit)
        drawChartLines(in: context, with: rect, speedViewData: speedViewData, unit: unitSpeed)
        
        if let featuredIndex = featuredIndex {
            let item = sondeData.values[featuredIndex]
            drawInfo(rect, in: context, for: item)
        }
    }
    
    func drawChartLines(in context: CGContext,
                        with rect: CGRect,
                        speedViewData: SpeedChartViewData,
                        unit: CGFloat) {
        let halfWidth = rect.width * 0.5
        
        // distanceをrect中の長さに合わせるために掛ける定数
        let multiple = halfWidth / unit * Self.radiusRatio
        // 最高と最低のheight
        let maxHeight = speedViewData.speedPoints.last?.altitude ?? 0
        let minHeight = speedViewData.speedPoints.first?.altitude ?? 0
        
        let sign: CGFloat = isTo ? 1 : -1
        
        speedViewData.speedPoints.enumerated().forEach { index, point in
            let alt = point.altitude
            let vector = point.speedPoint
            // scaleされた点
            let scaledVector = vector * multiple
            
            let lineWidth: CGFloat = index == featuredIndex ? 4 : 1
            context.setLineWidth(lineWidth)
            context.move(to: rect.mid)
            context.setStrokeColor(color(alt, max: maxHeight, min: minHeight).cgColor)
            context.addLine(to: rect.mid + sign * scaledVector)
            context.strokePath()
        }
    }
    
    func drawInfo(_ rect: CGRect, in context: CGContext, for item: SondeDataItem) {
        var attrs: [NSAttributedString.Key : Any] = [:]
        attrs[.foregroundColor] = UIColor.Palette.text
        attrs[.font] = UIFont.systemFont(ofSize: 9)
        
        var y: CGFloat = 5
        let offsetX: CGFloat = 10
        
        let text1 = "AGL: \(item.height)[m]"
        let size1 = text1.size(withAttributes: attrs)
        let point1: CGPoint = .init(x: rect.maxX - size1.width - offsetX, y: y)
        context.drawText(text1, at: point1, align: .left, angleRadians: 0, attributes: attrs)
        y += size1.height + 2
        
        let textMSL = "MSL: \(item.altitude)[m]"
        let sizeMSL = textMSL.size(withAttributes: attrs)
        let pointMSL: CGPoint = .init(x: rect.maxX - sizeMSL.width - offsetX, y: y)
        context.drawText(textMSL, at: pointMSL, align: .left, angleRadians: 0, attributes: attrs)
        y += sizeMSL.height + 2
        
        if let sondeData = sondeData {
            let deg = sondeData.degree(with: item, useTN: useTN, isFrom: !isTo)
            let windHeadingText = String(format: "%.0f", deg)
            let directionText = isTo ? "To" : "FROM"
            let northText = useTN ? "真北" : "磁北"
            
            let textWindHeading = "風向[\(directionText), \(northText)]: \(windHeadingText)°"
            let size2 = textWindHeading.size(withAttributes: attrs)
            let point2: CGPoint = .init(x: rect.maxX - size2.width - offsetX, y: y)
            context.drawText(textWindHeading, at: point2, align: .left, angleRadians: 0, attributes: attrs)
            y += size2.height + 2
        }
        
        let windSpeedText = String(format: "%.1f", speedUnit.converted(from: item.windspeed))
        let text3 = "Speed: \(windSpeedText)[\(speedUnit.rawValue)]"
        let size3 = text3.size(withAttributes: attrs)
        let point3: CGPoint = .init(x: rect.maxX - size3.width - offsetX, y: y)
        context.drawText(text3, at: point3, align: .left, angleRadians: 0, attributes: attrs)
    }
}

// MARK: - 下地

private extension SpeedChartView {
    func drawGrid(in context: CGContext, with rect: CGRect) {
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
        context.addCircle(center: rect.mid, with: radius * 4)
        context.addCircle(center: rect.mid, with: radius * 5)
        
        context.strokePath()
    }
    
    func calcUnitSpeed(_ maxSpeed: CGFloat) -> CGFloat {
        let tmpUnitSpeed = max(maxSpeed * Self.radiusRatio, 0.1)
        return tmpUnitSpeed.ceiledPrecition(2)
    }
    
    func drawScales(_ rect: CGRect, in context: CGContext, unitSpeed: CGFloat) {
        let unitVector: CGPoint = .init(x: 0, y: rect.width * 0.5 * Self.radiusRatio)
        
        var attrs: [NSAttributedString.Key : Any] = [:]
        attrs[.foregroundColor] = UIColor.gray
        attrs[.font] = UIFont.systemFont(ofSize: 9)
        
        for i in 1...5 {
            let scaleValue = unitSpeed * CGFloat(i)
            let text = "\(scaleValue.stringFixedTo2)[\(speedUnit.rawValue)]"
            let point: CGPoint = CGFloat(i) * unitVector + rect.mid
            let size = text.size(withAttributes: attrs)
            
            context.drawText(text, at: point - .init(x: -3, y: size.height * 0.5), align: .left, angleRadians: 0, attributes: attrs)
        }
    }
}

private extension SondeData {
    var maxSpeed: CGFloat {
        values.map { $0.windspeed }.max() ?? 0
    }
    
    var min: CGFloat {
        values.map { $0.windspeed }.min() ?? 0
    }
}

private extension SpeedChartView {
    // 青(低い高度)
    static let minHueColor: CGFloat = 255
    // 赤(高い高度)
    static let maxHueColor: CGFloat = -15
    
    func color(_ number: CGFloat, max: CGFloat, min: CGFloat) -> UIColor {
        let divisionRatio = (number - min) / (max - min)
        let clamped = divisionRatio.clamped(min: 0, max: 1)
        let hue = Self.minHueColor + clamped * (Self.maxHueColor - Self.minHueColor)
        return UIColor(hueDegree: hue, saturation: 1, brightness: 1, alpha: 1)
    }
}

