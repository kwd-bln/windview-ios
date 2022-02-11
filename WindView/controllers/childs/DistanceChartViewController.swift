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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(distanceChartView)
        distanceChartView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(distanceChartView.snp.height)
        }
    }
    
    func drawChart(by sondeData: [SondeData], with unit: CGFloat, isTo: Bool) {
        distanceChartView.drawChart(by: sondeData, with: .m, isTo: isTo)
    }
}
