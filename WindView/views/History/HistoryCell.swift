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
    
    private let mapButton: UIButton = {
        let button = UIButton.createImageTitleButton(
            image: UIImage(named: "map_icon")!.resize(size: .init(width: 32, height: 32))!,
            title: "MAP",
            height: 18)
        return button
    }()
    
    private var lat: CGFloat?
    private var lng: CGFloat?
    
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
        addSubview(mapButton)
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        placeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(79)
        }
        
        mapButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
        
        mapButton.addTarget(self, action: #selector(didPushMapButton(_:)), for: .touchUpInside)
    }
    
    func set(time: String, place: String, lat: CGFloat, lng: CGFloat) {
        timeLabel.text = time
        placeLabel.text = place
        self.lat = lat
        self.lng = lng
    }
    
    @objc func didPushMapButton(_ sender: UIButton) {
        guard let lat = lat, let lng = lng else {
            return
        }
        
        UIApplication.shared.openGoogleMap(lat: lat, lng: lng)
    }
}
