//
//  TimeSelectorButton.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/12.
//

import Foundation
import UIKit

final class TimeSelectorButton: UIButton {
    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        layer.cornerRadius = 4
        
        setBackgroundImage(color.image, for: .selected)
        setBackgroundImage(UIColor.clear.image, for: .normal)
        setBackgroundImage(color.withAlphaComponent(0.4).image, for: .highlighted)
        
        setTitle(text, for: .normal)
        setTitleColor(color, for: .normal)
        setTitleColor(UIColor.Palette.main, for: .selected)
        setTitleColor(UIColor.Palette.main, for: .highlighted)
        
        contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
