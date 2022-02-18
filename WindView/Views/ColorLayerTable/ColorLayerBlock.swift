//
//  ColorLayerBlock.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import Foundation
import UIKit

final class ColorLayerBlock: UIView {
    let degreeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Palette.text
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    let speedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Palette.text
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        return label
    }()
    
    let centerBorderView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        return view
    }()
    
    let bottomBorder: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        return view
    }()
    
    init(degree: String, speed: String, bgColor: UIColor) {
        super.init(frame: .zero)
        degreeLabel.text = degree
        speedLabel.text = speed
        backgroundColor = bgColor
        
        addSubview(centerBorderView)
        addSubview(degreeLabel)
        addSubview(speedLabel)
        
        snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        
        centerBorderView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
            make.left.equalTo(degreeLabel.snp.right)
        }
        
        degreeLabel.snp.makeConstraints {
            $0.width.equalTo(26)
            $0.top.left.bottom.equalToSuperview()
        }
        
        speedLabel.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-2)
            $0.left.equalTo(degreeLabel.snp.right)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
