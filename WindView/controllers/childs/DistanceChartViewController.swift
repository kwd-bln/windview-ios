//
//  DistanceChartViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit

final class DistanceChartViewController: UIViewController {
    private let distanceChartView = DistanceChartView()
    private let timeLabel: UILabel = .createDefaultLabel("", color: .Palette.grayText,
                                                         font: .hiraginoSans(style: .light, size: 12))
    
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
    }
    
    func drawChart(by sondeDataList: [SondeData], with unit: CGFloat, isTo: Bool) {
        distanceChartView.drawChart(by: sondeDataList, with: .m, isTo: isTo)
        if let sondeData = sondeDataList.first {
            let timeText = DateUtil.timeText(from: sondeData.updatedAt.dateValue())
            timeLabel.text = "更新 \(timeText)"
        }
    }
}
