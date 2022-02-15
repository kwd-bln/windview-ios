//
//  HeightLayerStackView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import UIKit

final class HeightLayerStackView: UIStackView {
    let maxHeightSondeData: SondeData
    
    init(_ maxHeightSondeData: SondeData) {
        self.maxHeightSondeData = maxHeightSondeData
        super.init(frame: .zero)
        setupSubviews()
    }
    
    private func setupSubviews() {
        axis = .vertical
        spacing = 1
        distribution = .fill
        alignment = .center
        
        let timeBlock = TextLayerBlock("", bgColor: .lightGray.withAlphaComponent(0.4))
        addArrangedSubview(timeBlock)
        
        maxHeightSondeData.values.reversed().forEach { dataItem in
            let text = String(format: "%.0f", dataItem.height)
            
            let textLayerBlock = TextLayerBlock(text, bgColor: .lightGray.withAlphaComponent(0.4))
            addArrangedSubview(textLayerBlock)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
