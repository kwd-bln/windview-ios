//
//  SpeedChartViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit

final class SpeedChartViewController: UIViewController {
    // 時間を選択するためのscrollView
    private let timeSelectorScrollView = UIScrollView()
    private let timeSelectorStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    private var timeList: [Date] = [] {
        didSet {
            updateTimeButtons()
        }
    }
    
    private let speedChartView = SpeedChartView()
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
        view.addSubview(speedChartView)
        speedChartView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(speedChartView.snp.height)
        }
        
        timeLabel.snp.makeConstraints {
            $0.bottom.equalTo(speedChartView.snp.top).offset(-12)
            $0.left.equalTo(speedChartView).offset(16)
        }
    }
    
    // MARK: viewの更新
    private func updateTimeButtons() {
        
    }
    
}

// MARK: - 外部に公開
extension SpeedChartViewController {
    func set(_ sondeDataList: [SondeData]) {
        timeList = sondeDataList.map { $0.measuredAt.dateValue() }
    }
    
    func drawChart(by sondeData: SondeData, isTo: Bool) {
        speedChartView.set(sondeData: sondeData)
        let timeText = DateUtil.timeText(from: sondeData.updatedAt.dateValue())
        timeLabel.text = "更新 \(timeText)"
    }
}
