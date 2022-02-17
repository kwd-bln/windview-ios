//
//  TextCell.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/13.
//

import UIKit

class TextCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? targetColor.withAlphaComponent(0.4) : currentBackgroundColor
            label.textColor = isHighlighted ? UIColor.Palette.main : titleColor
        }
    }
    
    var isFeatured: Bool = false {
        didSet {
            updateColor()
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor.Palette.grayText
        return label
    }()
    
    fileprivate var targetColor: UIColor = .white {
        didSet {
            updateColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.layer.cornerRadius = 4
        setupSubviews()
        let selected = UIView()
        self.selectedBackgroundView = selected
        
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        layer.cornerRadius = 4
        layer.borderWidth = 1
        
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private var currentBackgroundColor: UIColor? {
        isFeatured ? targetColor : nil
    }
    
    private var titleColor: UIColor {
        isFeatured ? UIColor.Palette.main : targetColor
    }
    
    private func updateColor() {
        layer.borderColor = targetColor.cgColor
        label.textColor = titleColor
        backgroundColor = currentBackgroundColor
    }
}

extension TextCell {
    static func feed(text: String, to cell: TextCell, color: UIColor) {
        cell.label.text = text
        cell.label.sizeToFit()
        cell.targetColor = color
    }
}
