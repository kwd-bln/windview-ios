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
    private let timeSelectorScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delaysContentTouches = false
        return sv
    }()
    
    private let timeCollectionView: SelfResizingCollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let collectionView = SelfResizingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .none
        return collectionView
    }()
    
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
            timeCollectionView.reloadData()
        }
    }
    
    private var numOfTimeList: Int {
        timeList.count
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
        
        timeCollectionView.register(TextCell.self, forCellWithReuseIdentifier: "\(TextCell.self)")
        timeCollectionView.delegate = self
        timeCollectionView.dataSource = self
        
        timeSelectorScrollView.addSubview(timeSelectorStack)
        
        view.addSubview(timeLabel)
        view.addSubview(speedChartView)
        view.addSubview(timeCollectionView)
        
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
        
        timeCollectionView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
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


// MARK: - UICollectionViewDelegate
extension SpeedChartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("clicked", indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SpeedChartViewController: UICollectionViewDelegateFlowLayout {
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
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = DateUtil.timeText(from: timeList[indexPath.row])
        label.sizeToFit()
        let size = label.frame.size
        return CGSize(width: size.width + 8, height: size.height + 9)
    }
}

// MARK: - UICollectionViewDataSource
extension SpeedChartViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numOfTimeList
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TextCell.self)", for: indexPath)
        guard let textCell = cell as? TextCell else { return cell }
        let text = DateUtil.timeText(from: timeList[indexPath.row])
        TextCell.feed(text: text,
                      to: textCell,
                      color: UIColor.number(numOfTimeList - indexPath.row - 1, max: numOfTimeList))
        return textCell
    }
}
