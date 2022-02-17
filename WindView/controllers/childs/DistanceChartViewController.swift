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
    // View
    private let distanceChartView = DistanceChartView()
    private let timeLabel: UILabel = .createDefaultLabel("", color: .Palette.grayText,
                                                         font: .hiraginoSans(style: .light, size: 12))
    
    // MARK: View
    private let timeCollectionView: SelfResizingCollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let collectionView = SelfResizingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .none
        return collectionView
    }()
    
    private let zoomButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "zoom"), for: .normal)
        button.tintColor = UIColor.Palette.grayText
        button.layer.borderColor = UIColor(hex: "444444").cgColor
        button.layer.borderWidth = 1
        button.contentEdgeInsets = .init(top: 6, left: 8, bottom: 6, right: 8)
        button.layer.cornerRadius = 3
        return button
    }()
    
    private let fromButton: UIButton = {
        let button = UIButton()
        button.setTitle("From", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.Palette.text, for: .normal)
        button.setBackgroundImage(UIColor.clear.image, for: .normal)
        button.setBackgroundImage(UIColor.systemYellow.withAlphaComponent(0.5).image, for: .selected)
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.cornerRadius = 3
        
        button.layer.borderColor = UIColor(hex: "444444").cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        
        return button
    }()
    
    // view model
    
    var zoomButtonTap: ControlEvent<Void> {
        zoomButton.rx.tap
    }
    
    var fromButtonTap: ControlEvent<Void> {
        fromButton.rx.tap
    }
    
    private(set) var sondeDataList: [SondeData] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        timeCollectionView.register(TextCell.self, forCellWithReuseIdentifier: "\(TextCell.self)")
        timeCollectionView.delegate = self
        timeCollectionView.dataSource = self
        
        view.addSubview(timeCollectionView)
        view.addSubview(timeLabel)
        view.addSubview(distanceChartView)
        view.addSubview(zoomButton)
        view.addSubview(fromButton)
        
        timeCollectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(12)
        }
        
        distanceChartView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(timeCollectionView.snp.bottom).offset(40)
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
        self.sondeDataList = sondeDataList
        timeCollectionView.reloadData()
        
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

// MARK: - UICollectionViewDelegateFlowLayout

extension DistanceChartViewController: UICollectionViewDelegateFlowLayout {
    static let sideInset: CGFloat = 8
    static let sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 16, right: 8)

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        Self.sectionInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 16)
        let date = sondeDataList[indexPath.row].measuredAt.dateValue()
        label.text = DateUtil.timeText(from: date)
        label.sizeToFit()
        let size = label.frame.size
        return CGSize(width: size.width + 12, height: size.height + 8)
    }
}

// MARK: - UICollectionViewDataSource

extension DistanceChartViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sondeDataList.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TextCell.self)", for: indexPath)
        guard let textCell = cell as? TextCell else { return cell }
        let date = sondeDataList[indexPath.row].measuredAt.dateValue()
        let text = DateUtil.timeText(from: date)
        let numOfSondeData = sondeDataList.count
        TextCell.feed(text: text,
                      to: textCell,
                      color: UIColor.number(numOfSondeData - indexPath.row - 1,
                                            max: numOfSondeData))
        return textCell
    }
}
