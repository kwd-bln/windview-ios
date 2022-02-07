//
//  CustomTextField.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/07.
//

import UIKit

class CustomTextField: UITextField {
    var padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    override var placeholder: String? {
        didSet {
            if placeholder != nil {
                attributedPlaceholder =
                NSAttributedString(string: placeholder!,
                                   attributes: [
                                    .foregroundColor: placeholderColor,
                                   ])
            }
        }
    }
    
    let placeholderColor = UIColor(hex: "989898")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        layer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        font = .hiraginoSans(style: .light, size: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
