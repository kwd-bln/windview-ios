//
//  ColorLayerTableViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit

final class ColorLayerTableViewController: UIViewController {
    
    private var sondeDataList: [SondeData] = [] {
        didSet {
            updateViews()
        }
    }
    
    private let horizontalStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .fill
        stack.spacing = 1
        return stack
    }()
    
    private var layerStackViews: [LayerStackView] = []
    private var useTN: Bool = true
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(16)
        }
    }
    
    private func updateViews() {
        horizontalStack.subviews.forEach { $0.removeFromSuperview() }
        
        guard let maxHeightSondeData = sondeDataList.max(by: { $0.values.count < $1.values.count }) else { return }
        let heightStack = HeightLayerStackView(maxHeightSondeData)
        horizontalStack.addArrangedSubview(heightStack)
        
        let maxCount: Int = maxHeightSondeData.values.count
        layerStackViews = sondeDataList.map { LayerStackView($0, count: maxCount, useTN: useTN) }
        layerStackViews.forEach { v in
            horizontalStack.addArrangedSubview(v)
        }
    }
    
    func set(_ sondeDataList: [SondeData], useTN: Bool) {
        self.sondeDataList = sondeDataList
        self.useTN = useTN
    }
}
