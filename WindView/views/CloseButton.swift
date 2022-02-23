//
//  CloseButton.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/16.
//

import UIKit

class CloseButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        let image = UIImage(systemName: "xmark.circle.fill")
        setImage(image, for: .normal)
        imageView?.snp.makeConstraints({ make in
            make.width.height.equalTo(28)
        })
        snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        tintColor = .lightGray.withAlphaComponent(0.6)
    }
}
