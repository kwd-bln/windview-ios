//
//  TextLayerBlock.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import UIKit

final class TextLayerBlock: UIView {
    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "222222")
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    let bottomBorder: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        return view
    }()
    
    init(_ text: String, bgColor: UIColor) {
        super.init(frame: .zero)
        textLabel.text = text
        backgroundColor = bgColor
        addSubview(textLabel)
        
        snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 17))
        }
        
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
