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
import BetterSegmentedControl

final class DistanceChartViewController: UIViewController {
    // MARK: View
    private let distanceChartView = DistanceChartView()
    private let timeLabel: UILabel = .createDefaultLabel("", color: .Palette.grayText,
                                                         font: .hiraginoSans(style: .light, size: 12))
    
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
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.cornerRadius = 3
        return button
    }()
    
    private let toFromSegmentedControl = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: ["TO", "FROM"],
                                        normalTextColor: UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9),
                                        selectedTextColor: UIColor(red: 0.16, green: 0.40, blue: 0.96, alpha: 1.00)),
        options: [.backgroundColor(UIColor(red: 0.6, green: 0.7, blue: 0.98, alpha: 1)),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(18)]
    )
    
    private let mapButton: UIButton = .createImageTitleButton(
        image: UIImage(named: "map_icon")!.resize(size: .init(width: 32, height: 32))!,
        title: "MAP",
        height: 18)
    
    private let placeLabel: UILabel = .createDefaultLabel("",
                                                          color: .Palette.grayText,
                                                          font: .systemFont(ofSize: 12))
    
    // view model
    
    var zoomButtonTap: ControlEvent<Void> {
        zoomButton.rx.tap
    }
    
    var isFromSegmentSelectedRelay: BehaviorRelay<Bool> = .init(value: false)
    
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
        
        toFromSegmentedControl.addTarget(self,
                                         action: #selector(toFromSegmentedControlValueChanged(_:)),
                                         for: .valueChanged)
        
        mapButton.addTarget(self, action: #selector(didPushMapButton(_:)), for: .touchUpInside)
        
        view.addSubview(timeCollectionView)
        view.addSubview(timeLabel)
        view.addSubview(distanceChartView)
        view.addSubview(zoomButton)
        view.addSubview(toFromSegmentedControl)
        view.addSubview(mapButton)
        view.addSubview(placeLabel)
        
        timeCollectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(distanceChartView.snp.bottom).offset(16)
        }
        
        distanceChartView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(60)
            $0.width.equalTo(distanceChartView.snp.height)
        }
        
        timeLabel.snp.makeConstraints {
            $0.bottom.equalTo(distanceChartView.snp.top).offset(-12)
            $0.left.equalTo(distanceChartView).offset(16)
        }
        
        toFromSegmentedControl.snp.makeConstraints { make in
            make.bottom.equalTo(distanceChartView.snp.top).offset(-8)
            make.right.equalTo(distanceChartView).offset(-12)
            make.height.equalTo(36)
        }
        
        zoomButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 40, height: 40))
            $0.right.equalTo(distanceChartView).offset(-8)
            $0.bottom.equalTo(distanceChartView).offset(-8)
        }
        
        mapButton.snp.makeConstraints { make in
            make.top.equalTo(distanceChartView).offset(4)
            make.left.equalTo(distanceChartView).offset(4)
        }
        
        placeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(mapButton)
            make.left.equalTo(mapButton.snp.right)
        }
    }
    
    func drawChart(by sondeDataList: [SondeData], with size: ChartSize, isTo: Bool, useTN: Bool) {
        self.sondeDataList = sondeDataList
        timeCollectionView.reloadData()
        
        distanceChartView.set(sondeDataList)
        distanceChartView.set(size)
        distanceChartView.set(isTo)
        distanceChartView.set(useTN: useTN)
        if let sondeData = sondeDataList.first {
            let timeText = DateUtil.timeText(from: sondeData.updatedAt.dateValue())
            timeLabel.text = "更新 \(timeText)"
        }
        
        if let locationText = sondeDataList.first?.locationText {
            placeLabel.text = locationText
        }
    }
}

// MARK: - objc methods

extension DistanceChartViewController {
    @objc private func toFromSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        isFromSegmentSelectedRelay.accept(sender.index == 1)
    }
    
    @objc private func didPushMapButton(_ sender: UIButton) {
        if let firstSondeData = sondeDataList.first {
            UIApplication.shared.openGoogleMap(lat: firstSondeData.lat, lng: firstSondeData.lng)
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
