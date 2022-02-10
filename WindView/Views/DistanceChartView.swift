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
    
    // 角度からラジアンに変換
    func toRadian(_ angle: CGFloat) -> CGFloat {
        return angle * CGFloat.pi / 180
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 下地

extension DistanceChartView {
    func drawGrid(_ rect: CGRect) {
        let path = UIBezierPath()

        path.lineWidth = 1
        let halfWidth = rect.width / 2
        let length30 = halfWidth * tan(self.toRadian(30))
        
        print(halfWidth, length30)
        
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
        path.addArc(withCenter: rect.mid, radius: radius * 1, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        path.addArc(withCenter: rect.mid, radius: radius * 2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        path.addArc(withCenter: rect.mid, radius: radius * 3, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        path.close()

        UIColor.gray.setStroke()
        path.stroke()
    }
}
