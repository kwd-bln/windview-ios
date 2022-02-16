//
//  HistoryCell.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/16.
//

import UIKit

class HistoryCell: UITableViewCell {
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "485fc7")
        return label
    }()
    
    private let placeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.textColor = .Palette.text
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        addSubview(timeLabel)
        addSubview(placeLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        placeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(79)
        }
    }
    
    func set(time: String, place: String) {
        timeLabel.text = time
        placeLabel.text = place
    }
}
