//
//  ColorLayerTableViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit
import BetterSegmentedControl

final class ColorLayerTableViewController: UIViewController {
    
    // MARK: - data
    
    private var sondeDataList: [SondeData] = [] {
        didSet {
            updateViews()
        }
    }
    
    private var useTN: Bool = true
    private var speedUnit: SpeedUnit = UserDefaults.standard.speedUnit
    private var altUnit: AltUnit = UserDefaults.standard.altUnit
    
    private var isFrom: Bool = false {
        didSet {
            if isFrom != oldValue {
                updateViews()
            }
        }
    }
    
    // MARK: - views
    
    private let horizontalStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .fill
        stack.spacing = 1
        return stack
    }()
    
    private var layerStackViews: [LayerStackView] = []
    
    private let toFromSegmentedControl = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: ["TO", "FROM"],
                                        normalTextColor: UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9),
                                        selectedTextColor: UIColor(red: 0.16, green: 0.40, blue: 0.96, alpha: 1.00)),
        options: [.backgroundColor(UIColor(red: 0.6, green: 0.7, blue: 0.98, alpha: 1)),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(18)]
    )
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        toFromSegmentedControl.addTarget(self,
                                         action: #selector(toFromSegmentedControlValueChanged(_:)),
                                         for: .valueChanged)
        
        view.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(16)
        }
        
        view.addSubview(toFromSegmentedControl)
        toFromSegmentedControl.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(horizontalStack.snp.top).offset(-8)
            make.height.equalTo(36)
        }
    }
    
    private func updateViews() {
        horizontalStack.subviews.forEach { $0.removeFromSuperview() }
        
        guard let maxHeightSondeData = sondeDataList.max(by: { $0.values.count < $1.values.count }) else { return }
        let heightStack = HeightLayerStackView(maxHeightSondeData, isHeight: true, altUnit: altUnit)
        horizontalStack.addArrangedSubview(heightStack)
        let altStack = HeightLayerStackView(maxHeightSondeData, isHeight: false, altUnit: altUnit)
        horizontalStack.addArrangedSubview(altStack)
        
        let maxCount: Int = maxHeightSondeData.values.count
        layerStackViews = sondeDataList.reversed().map { LayerStackView($0,
                                                                        count: maxCount,
                                                                        useTN: useTN,
                                                                        isFrom: isFrom,
                                                                        speedUnit: speedUnit) }
        layerStackViews.forEach { v in
            horizontalStack.addArrangedSubview(v)
        }
    }
    
    func set(
        _ sondeDataList: [SondeData],
        useTN: Bool,
        speedUnit: SpeedUnit,
        altUnit: AltUnit
    ) {
        self.useTN = useTN
        self.speedUnit = speedUnit
        self.altUnit = altUnit
        self.sondeDataList = sondeDataList
    }
}

// MARK: - segment control

extension ColorLayerTableViewController {
    @objc private func toFromSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        isFrom = sender.index == 1
    }
}
