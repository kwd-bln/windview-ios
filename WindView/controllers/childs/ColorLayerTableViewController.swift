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
            make.top.left.equalToSuperview()
        }
    }
    
    private func updateViews() {
        layerStackViews = sondeDataList.map { LayerStackView($0) }
        layerStackViews.forEach { v in
            horizontalStack.addArrangedSubview(v)
        }
    }
    
    func set(_ sondeDataList: [SondeData]) {
        self.sondeDataList = sondeDataList
    }
}
