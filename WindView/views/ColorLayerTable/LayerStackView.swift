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
    
    init(_ sondeData: SondeData) {
        self.sondeData = sondeData
        super.init(frame: .zero)
        setupSubviews()
    }
    
    private func setupSubviews() {
        axis = .vertical
        spacing = 1
        distribution = .fill
        alignment = .center
        
        sondeData.values.forEach { dataItem in
            let deg = String(Int(dataItem.windheading.rounded()))
            let speed = String(format: "%.1f", dataItem.windspeed)
            let colorLayerBlock = ColorLayerBlock(degree: deg,
                                                  speed: speed,
                                                  bgColor: .red)
            addArrangedSubview(colorLayerBlock)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
