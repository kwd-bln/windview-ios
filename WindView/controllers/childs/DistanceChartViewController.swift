//
//  DistanceChartViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

final class DistanceChartViewController: UIViewController {
    private let distanceChartView = DistanceChartView()
    private let timeLabel: UILabel = .createDefaultLabel("", color: .Palette.grayText,
                                                         font: .hiraginoSans(style: .light, size: 12))
    
    private let zoomButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "zoom"), for: .normal)
        button.tintColor = UIColor.Palette.grayText
        button.layer.borderColor = UIColor(hex: "444444").cgColor
        button.layer.borderWidth = 1
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.cornerRadius = 3
        return button
    }()
    
    private let fromButton: UIButton = {
        let button = UIButton()
        button.setTitle("From", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.Palette.text, for: .normal)
        button.setBackgroundImage(UIColor.clear.image, for: .normal)
        button.setBackgroundImage(UIColor.red.withAlphaComponent(0.5).image, for: .selected)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.layer.cornerRadius = 3
        
        button.layer.borderColor = UIColor(hex: "444444").cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        
        return button
    }()
    
    
    var zoomButtonTap: ControlEvent<Void> {
        zoomButton.rx.tap
    }
    
    var fromButtonTap: ControlEvent<Void> {
        fromButton.rx.tap
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(timeLabel)
        view.addSubview(distanceChartView)
        view.addSubview(zoomButton)
        view.addSubview(fromButton)
        distanceChartView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(distanceChartView.snp.height)
        }
        
        timeLabel.snp.makeConstraints {
            $0.bottom.equalTo(distanceChartView.snp.top).offset(-12)
            $0.left.equalTo(distanceChartView).offset(16)
        }
        
        fromButton.snp.makeConstraints {
            $0.bottom.equalTo(distanceChartView.snp.top).offset(-8)
            $0.right.equalTo(distanceChartView).offset(-12)
        }
        
        zoomButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 40, height: 40))
            $0.right.equalTo(distanceChartView).offset(-8)
            $0.bottom.equalTo(distanceChartView).offset(-8)
        }
    }
    
    func drawChart(by sondeDataList: [SondeData], with size: ChartSize, isTo: Bool) {
        distanceChartView.set(sondeDataList)
        distanceChartView.set(size)
        distanceChartView.set(isTo)
        fromButton.isSelected = !isTo
        if let sondeData = sondeDataList.first {
            let timeText = DateUtil.timeText(from: sondeData.updatedAt.dateValue())
            timeLabel.text = "更新 \(timeText)"
        }
    }
}
