//
//  UIButton+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/16.
//

import UIKit

extension UIButton {
    static func createMenuButton(text: String, textColor: UIColor = .Palette.main) -> UIButton {
        let uiButton = UIButton()
        uiButton.setTitle(text, for: .normal)
        uiButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        uiButton.sizeToFit()
        let size: CGSize = .init(width: uiButton.frame.width + 20, height: uiButton.frame.height)
        uiButton.frame.size = size
        uiButton.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        uiButton.setTitleColor(textColor, for: .normal)
        return uiButton
    }
    
    static func createImageTitleButton(image: UIImage,
                                       title: String,
                                       height: CGFloat,
                                       tintColor: UIColor? = nil) -> UIButton {
        let uiButton = UIButton(type: .system)
        uiButton.setTitle(title, for: .normal)
        uiButton.setImage(image, for: .normal)
        uiButton.titleLabel?.font = .systemFont(ofSize: 12)
        let titleSize = title.size(with: .systemFont(ofSize: 12))
        uiButton.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: titleSize.width)
        uiButton.titleEdgeInsets = .init(top: 0, left: -titleSize.width + 8, bottom: 0, right: 0)
        
        uiButton.imageView?.contentMode = .scaleAspectFit
        uiButton.contentHorizontalAlignment = .fill
        uiButton.contentVerticalAlignment = .fill
        uiButton.clipsToBounds = true
        
        uiButton.snp.makeConstraints { make in
            make.height.equalTo(height)
            make.width.equalTo(height + titleSize.width + 10)
        }
        
        if let tintColor = tintColor {
            uiButton.tintColor = .red
        }
        
        return uiButton
    }
}
