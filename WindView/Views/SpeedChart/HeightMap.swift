//
//  HeightMap.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/20.
//

import UIKit
import RxCocoa
import RxSwift

class HeightMap: UIStackView {
    private let disposeBag = DisposeBag()
    private let selectedIndexRelay: BehaviorRelay<Int?> = .init(value: nil)
    private var heightBoxes: [HeightBox] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .vertical
        alignment = .center
        distribution = .fill
        spacing = 0
        
        selectedIndexRelay.asDriver()
            .drive(onNext: { [weak self] selectedIndex in
                self?.updateHeightBoxes(to: selectedIndex)
            })
            .disposed(by: disposeBag)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(speedViewData: SpeedChartViewData) {
        heightBoxes = []
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        let maxHeight = speedViewData.speedPoints.last?.altitude ?? 0
        let minHeight = speedViewData.speedPoints.first?.altitude ?? 0
        
        speedViewData.speedPoints.enumerated().reversed().forEach { index, points in
            let alt = points.altitude
            let color = color(alt, max: maxHeight, min: minHeight)
            let altInt = Int(alt)
            let textBlock = HeightBox(String(altInt), color: color, heightIndex: index)
            addArrangedSubview(textBlock)
            heightBoxes.append(textBlock)
        }
    }
    
    func updateHeightBoxes(to index: Int?) {
        heightBoxes.forEach { box in
            box.isFeatured = box.index == index
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! //このタッチイベントの場合確実に1つ以上タッチ点があるので`!`つけてOKです
        let location = touch.location(in: self) //in: には対象となるビューを入れます
        if let view = hitTest(location, with: event), let heightBox = view as? HeightBox {
            selectedIndexRelay.accept(heightBox.index)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! //このタッチイベントの場合確実に1つ以上タッチ点があるので`!`つけてOKです
        let location = touch.location(in: self) //in: には対象となるビューを入れます
        if let view = hitTest(location, with: event), let heightBox = view as? HeightBox {
            selectedIndexRelay.accept(heightBox.index)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedIndexRelay.accept(nil)
    }
}

private extension HeightMap {
    // 青(低い高度)
    static let minHueColor: CGFloat = 255
    // 赤(高い高度)
    static let maxHueColor: CGFloat = -15
    
    func color(_ number: CGFloat, max: CGFloat, min: CGFloat) -> UIColor {
        let divisionRatio = (number - min) / (max - min)
        let clamped = divisionRatio.clamped(min: 0, max: 1)
        let hue = Self.minHueColor + clamped * (Self.maxHueColor - Self.minHueColor)
        return UIColor(hueDegree: hue, saturation: 1, brightness: 1, alpha: 1)
    }
}

private class HeightBox: UIView {
    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Palette.text
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var isFeatured: Bool = false {
        didSet {
            if isFeatured != oldValue {
                update()
            }
        }
    }
    
    let color: UIColor
    let index: Int
    
    init(_ text: String, color: UIColor, heightIndex: Int) {
        self.color = color
        self.index = heightIndex
        super.init(frame: .zero)
        backgroundColor = .white
        textLabel.text = text
        addSubview(textLabel)
        
        snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 30, height: 15))
        }
        
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        if isFeatured {
            textLabel.textColor = .white
            backgroundColor = color
        } else {
            textLabel.textColor = .black
            backgroundColor = color.withAlphaComponent(0.3)
        }
    }
}
