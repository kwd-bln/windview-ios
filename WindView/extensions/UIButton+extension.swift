//
//  UIButton+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/16.
//

import UIKit

extension UIButton {
    static func createMenuButton(text: String, textColor: UIColor = .Palette.text) -> UIButton {
        let uiButton = UIButton()
        uiButton.setTitle(text, for: .normal)
        uiButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        uiButton.sizeToFit()
        let size: CGSize = .init(width: uiButton.frame.width + 16, height: uiButton.frame.height)
        uiButton.frame.size = size
        uiButton.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        uiButton.setTitleColor(textColor, for: .normal)
        return uiButton
    }
}
