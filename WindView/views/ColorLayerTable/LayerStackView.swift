//
//  LayerStackView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import Foundation
import UIKit

final class LayerStackView: UIStackView {
    private static let maxAlpha: CGFloat = 0.9
    private static let minAlpha: CGFloat = 0.2
    private static let maxSpeed: CGFloat = 15
    
    let sondeData: SondeData
    let count: Int
    
    init(_ sondeData: SondeData, count: Int) {
        self.count = count
        self.sondeData = sondeData
        super.init(frame: .zero)
        setupSubviews()
    }
    
    private func setupSubviews() {
        axis = .vertical
        spacing = 1
        distribution = .fill
        alignment = .center
        
        let date = sondeData.measuredAt.dateValue()
        let text = DateUtil.timeText(from: date)
        let timeBlock = TextLayerBlock(text, bgColor: .lightGray.withAlphaComponent(0.5))
        addArrangedSubview(timeBlock)
        
        let valueCounts = sondeData.values.count
        
        for i in (0 ..< count).reversed() {
            if i < valueCounts {
                let dataItem = sondeData.values[i]
                let deg = String(Int(dataItem.windheading.rounded()))
                let speed = String(format: "%.1f", dataItem.windspeed)
                let color = calcColor(from: dataItem)
                let colorLayerBlock = ColorLayerBlock(degree: deg,
                                                      speed: speed,
                                                      bgColor: color)
                addArrangedSubview(colorLayerBlock)
            } else {
                let textLayerBlock = TextLayerBlock("-", bgColor: .lightGray.withAlphaComponent(0.5))
                addArrangedSubview(textLayerBlock)
            }
        }
    }
    
    private func calcColor(from sondeDataItem: SondeDataItem) -> UIColor {
        let hueDegree = sondeDataItem.windheading
        let slappedSpd = min(Self.maxSpeed, sondeDataItem.windspeed)
        let alpha = (Self.minAlpha * (Self.maxSpeed - slappedSpd) + Self.maxAlpha * slappedSpd) / Self.maxSpeed
        return UIColor(hueDegree: hueDegree, saturation: 0.8, brightness: 0.8, alpha: alpha)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
