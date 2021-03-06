//
//  SpeedChartViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/10.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import BetterSegmentedControl

final class SpeedChartViewController: UIViewController {
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
    
    private let toFromSegmentedControl = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: ["TO", "FROM"],
                                        normalTextColor: UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9),
                                        selectedTextColor: UIColor(red: 0.16, green: 0.40, blue: 0.96, alpha: 1.00)),
        options: [.backgroundColor(UIColor(red: 0.6, green: 0.7, blue: 0.98, alpha: 1)),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(18)]
    )
    
    private let speedChartView = SpeedChartView()
    private let timeLabel: UILabel = .createDefaultLabel("", color: .Palette.grayText,
                                                         font: .hiraginoSans(style: .light, size: 12))
    private let heightMap = HeightMap(frame: .zero)
    
    private let mapButton: UIButton = .createImageTitleButton(
        image: UIImage(named: "map_icon")!.resize(size: .init(width: 32, height: 32))!,
        title: "MAP",
        height: 18)
    
    private let placeLabel: UILabel = .createDefaultLabel("",
                                                          color: .Palette.grayText,
                                                          font: .systemFont(ofSize: 12))
    
    // MARK: - viewModel
    
    let viewModel: SpeedViewModelType

    // MARK: その他
    let disposeBag = DisposeBag()
    
    init(viewModel: SpeedViewModelType = SpeedChartViewModel()) {
        self.viewModel = viewModel
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
        
        toFromSegmentedControl.addTarget(self, action: #selector(toFromSegmentedControlValueChanged(_:)), for: .valueChanged)
        
        heightMap.selectedIndexSignal
            .bind(to: viewModel.inputs.selectedHieightIndexValueChanged)
            .disposed(by: disposeBag)
        
        mapButton.rx.tap
            .bind(to: viewModel.inputs.mapButtonTap)
            .disposed(by: disposeBag)
        
        setupSubviews()
        
        Driver.combineLatest(
            viewModel.outputs.sondeDataList,
            viewModel.outputs.selectedIndex,
            viewModel.outputs.isFrom,
            viewModel.outputs.selectedHeightIndex,
            viewModel.outputs.useTN,
            viewModel.outputs.speedUnit
        ).drive { [weak self] sondeDataList, selectedIndex, isFrom, selectedHeightIndex, useTN, speedUnit in
            if sondeDataList.count == 0 { return }
            self?.speedChartView.set(sondeData: sondeDataList[selectedIndex],
                                     isFrom: isFrom,
                                     featuredIndex: selectedHeightIndex,
                                     useTN: useTN,
                                     speedUnit: speedUnit)
            self?.updateText(by: sondeDataList[selectedIndex])
            self?.timeCollectionView.reloadData()
        }.disposed(by: disposeBag)
        
        Driver.combineLatest(
            viewModel.outputs.sondeDataList,
            viewModel.outputs.selectedIndex
        ).drive { [weak self] sondeDataList, selectedIndex in
            if sondeDataList.count == 0 { return }
            let sondeData = sondeDataList[selectedIndex]
            self?.placeLabel.text = sondeData.locationText
            
            let spdData = SpeedChartViewData(from: sondeData, useTN: true)
            self?.heightMap.set(speedViewData: spdData)
        }.disposed(by: disposeBag)
        
        viewModel.outputs.mapSondeData
            .drive(onNext: { sondeData in
                guard let sondeData = sondeData else { return }
                UIApplication.shared.openGoogleMap(lat: sondeData.lat, lng: sondeData.lng)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeCollectionView.reloadData()
    }
}

// MARK: - setup subviews

private extension SpeedChartViewController {
    func setupSubviews() {
        view.addSubview(timeLabel)
        view.addSubview(heightMap)
        view.addSubview(speedChartView)
        view.addSubview(timeCollectionView)
        view.addSubview(toFromSegmentedControl)
        view.addSubview(mapButton)
        view.addSubview(placeLabel)
        
        timeCollectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(speedChartView.snp.bottom).offset(16)
        }
        
        timeLabel.snp.makeConstraints {
            $0.bottom.equalTo(speedChartView.snp.top).offset(-12)
            $0.left.equalTo(speedChartView).offset(16)
        }
        
        heightMap.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalTo(speedChartView.snp.bottom).offset(-8)
        }
        
        speedChartView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(heightMap.snp.left).offset(-4)
            $0.top.equalToSuperview().offset(60)
            $0.width.equalTo(speedChartView.snp.height)
        }
        
        toFromSegmentedControl.snp.makeConstraints { make in
            make.bottom.equalTo(speedChartView.snp.top).offset(-8)
            make.right.equalTo(speedChartView).offset(-12)
            make.height.equalTo(36)
        }
        
        mapButton.snp.makeConstraints { make in
            make.top.equalTo(speedChartView).offset(4)
            make.left.equalTo(speedChartView).offset(4)
        }
        
        placeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(mapButton)
            make.left.equalTo(mapButton.snp.right)
        }
    }
}

// MARK: - 外部に公開
private extension SpeedChartViewController {
    func updateText(by sondeData: SondeData) {
        let timeText = DateUtil.timeText(from: sondeData.updatedAt.dateValue())
        timeLabel.text = "更新 \(timeText)"
    }
}

// MARK: - objc
private extension SpeedChartViewController {
    @objc func toFromSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        viewModel.inputs.isFromSegmentControlChanged.onNext(sender.index == 1)
    }
}


// MARK: - UICollectionViewDelegate
extension SpeedChartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.inputs.timeButtonTap.onNext(indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TextCell.self)", for: indexPath)
        cell.isSelected = true
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
        label.font = UIFont.systemFont(ofSize: 16)
        let date = viewModel.presenter.sondeData(at: indexPath.row).measuredAt.dateValue()
        label.text = DateUtil.timeText(from: date)
        label.sizeToFit()
        let size = label.frame.size
        return CGSize(width: size.width + 12, height: size.height + 8)
    }
}

// MARK: - UICollectionViewDataSource
extension SpeedChartViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.presenter.numOfSondeData
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TextCell.self)", for: indexPath)
        guard let textCell = cell as? TextCell else { return cell }
        let date = viewModel.presenter.sondeData(at: indexPath.row).measuredAt.dateValue()
        let text = DateUtil.timeText(from: date)
        TextCell.feed(text: text,
                      to: textCell,
                      color: UIColor.number(viewModel.presenter.numOfSondeData - indexPath.row - 1,
                                            max: viewModel.presenter.numOfSondeData))
        textCell.isFeatured = viewModel.presenter.selectedIndexValue == indexPath.row
        return textCell
    }
}
