//
//  LayerStackView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import Foundation
import UIKit

final class LayerStackView: UIStackView {
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
        
        let valueCounts = sondeData.values.count
        
        for i in (0 ..< count).reversed() {
            if i < valueCounts {
                let dataItem = sondeData.values[i]
                let deg = String(Int(dataItem.windheading.rounded()))
                let speed = String(format: "%.1f", dataItem.windspeed)
                let color = UIColor(hueDegree: dataItem.windheading,
                                    saturation: 0.8,
                                    brightness: 0.8,
                                    alpha: 0.5)
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
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
