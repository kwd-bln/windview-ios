//
//  BottomControlView.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import UIKit

class BottomControlView: UIView {
    
    let settingView = BottomButtonView(
        frame: .zero,
        width: 50,
        image: UIImage(systemName: "gear"),
        imageWidth: 32
    )
    
    let historyButton = BottomButtonView(
        frame: .zero,
        width: 50,
        image: UIImage(systemName: "calendar"),
        imageWidth: 32
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        let baseStackView = UIStackView(arrangedSubviews: [settingView, historyButton])
        baseStackView.axis = .horizontal
        baseStackView.distribution = .fillEqually
        baseStackView.spacing = 20
        addSubview(baseStackView)
        
        baseStackView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BottomButtonView: UIView {
    let button: BoundButton
    
    init(frame: CGRect, width: CGFloat, image: UIImage?, imageWidth: CGFloat?) {
        button = BoundButton(type: .custom)
        super.init(frame: frame)
        
        button.setImage(image, for: .normal)
        
        if let imageWidth = imageWidth {
            button.imageView?.snp.makeConstraints({ make in
                make.width.height.equalTo(imageWidth)
            })
        }
        button.backgroundColor = .white
        button.layer.cornerRadius = width / 2
    
        button.layer.shadowOffset = .init(width: 1.5, height: 2)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 15
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(width)
        }
        
        button.tintColor = .systemBlue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
