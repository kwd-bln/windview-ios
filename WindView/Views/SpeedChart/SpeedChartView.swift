//
//  SpeedChartView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import UIKit

final class SpeedChartView: UIView {
    static let radiusRatio: CGFloat = 0.19
    
    private let drawingView = UIView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .Palette.main
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
        addSubview(drawingView)
        drawingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawGrid(rect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - draw chart

extension SpeedChartView {
    func drawChart(by sondeData: SondeData, isTo: Bool) {
        // calculate max speed
        let maxSpeed = sondeData.maxSpeed
        // 単位となる速度
        let unitSpeed = calcUnitSpeed(maxSpeed)
        
        drawScales(unitSpeed)
        
    }
}

// MARK: - 下地

private extension SpeedChartView {
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
        path.addCircle(center: rect.mid, with: radius * 4)
        path.addCircle(center: rect.mid, with: radius * 5)
        
        path.close()
        UIColor.gray.setStroke()
        path.stroke()
    }
    
    func calcUnitSpeed(_ maxSpeed: CGFloat) -> CGFloat {
        let tmpUnitSpeed = min(maxSpeed * Self.radiusRatio, 0.1)
        return tmpUnitSpeed.toPrecition(2)
    }
    
    func drawScales(_ unitSpeed: CGFloat) {
        let unitVector: CGPoint = .init(x: 0, y: bounds.width * 0.5 * Self.radiusRatio)
        
        let rounded = unitSpeed
        
        for i in 1...5 {
            let scaleValue = rounded * CGFloat(i)
            let text = scaleValue.stringFixedTo2
            let textLayer = CATextLayer.createTextLayer("\(text)[m/s]", fontSize: 8)
            let size = textLayer.preferredFrameSize()
            textLayer.bounds = CGRect(origin: .zero, size: size)
            textLayer.frame.origin = CGFloat(i) * unitVector + bounds.mid - .init(x: -4, y: size.height)
            textLayer.contentsScale = UIScreen.main.scale
            drawingView.layer.addSublayer(textLayer)
        }
    }
}


private extension SondeData {
    var maxSpeed: CGFloat {
        values.map { $0.windspeed }.max() ?? 0
    }
}
