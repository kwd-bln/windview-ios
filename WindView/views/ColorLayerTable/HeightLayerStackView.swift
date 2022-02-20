//
//  HeightLayerStackView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import UIKit

final class HeightLayerStackView: UIStackView {
    let maxHeightSondeData: SondeData
    /// true -> AGL false -> MSL
    let isHeight: Bool
    
    init(_ maxHeightSondeData: SondeData, isHeight: Bool) {
        self.maxHeightSondeData = maxHeightSondeData
        self.isHeight = isHeight
        super.init(frame: .zero)
        setupSubviews()
    }
    
    private func setupSubviews() {
        axis = .vertical
        spacing = 1
        distribution = .fill
        alignment = .center
        
        let titleText = isHeight ? "AGL" : "MSL"
        let timeBlock = TextLayerBlock(titleText, bgColor: .lightGray.withAlphaComponent(0.4), width: 40)
        addArrangedSubview(timeBlock)
        
        maxHeightSondeData.values.reversed().forEach { dataItem in
            let usedHeight = isHeight ? dataItem.height : dataItem.altitude
            let text = String(format: "%.0f", usedHeight)
            
            let textLayerBlock = TextLayerBlock(text, bgColor: .lightGray.withAlphaComponent(0.4), width: 40)
            addArrangedSubview(textLayerBlock)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
