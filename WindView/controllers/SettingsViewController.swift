//
//  SettingsViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/19.
//

import UIKit
import BetterSegmentedControl

final class SettingsViewController: UIViewController {
    // MARK: - temporary values
    var tmpIsTrueNorth: Bool = UserDefaults.standard.isTrueNorth
    var tmpChartDisplayDuration = UserDefaults.standard.chartDisplayDuration
    var tmpSpeedUnit = UserDefaults.standard.speedUnit
    var tmpAltUnit = UserDefaults.standard.altUnit
    
    // MARK: - views
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .hiraginoSans(style: .bold, size: 13)
        label.textColor = .Palette.text
        label.text = "設定"
        return label
    }()
    
    private let closeButton: UIButton = CloseButton(frame: .zero)
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("保存", for: .normal)
        button.titleLabel?.font = .hiraginoSans(style: .light, size: 14)
        return button
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private let directionLabel = createTitleLabel("方角")
    /// 磁北・真北
    private let directionSegmentedControl = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: ["磁北", "真北"],
                                        normalTextColor: UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9),
                                        selectedTextColor: UIColor(red: 0.16, green: 0.40, blue: 0.96, alpha: 1.00)),
        options: [.backgroundColor(UIColor(red: 0.6, green: 0.7, blue: 0.98, alpha: 1)),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(4)]
    )
    
    private let unitLabel = createTitleLabel("単位", size: 20)
    private let speedUnitLabel = createTitleLabel("風速")
    /// 風速の単位を変更するSegmentedControl
    private let speedUnitSegmentedControl = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: SpeedUnit.allCases.map { $0.rawValue },
                                        normalTextColor: UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9),
                                        selectedTextColor: UIColor(red: 0.16, green: 0.40, blue: 0.96, alpha: 1.00)),
        options: [.backgroundColor(UIColor(red: 0.6, green: 0.7, blue: 0.98, alpha: 1)),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(4)]
    )
    private let altUnitLabel = createTitleLabel("高度")
    /// 高度の単位を変更するSegmentedControl
    private let altUnitSegmentedControl = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: AltUnit.allCases.map { $0.rawValue },
                                        normalTextColor: UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9),
                                        selectedTextColor: UIColor(red: 0.16, green: 0.40, blue: 0.96, alpha: 1.00)),
        options: [.backgroundColor(UIColor(red: 0.6, green: 0.7, blue: 0.98, alpha: 1)),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(4)]
    )
    
    
    private let chartDurationTitleLabel = createTitleLabel("チャート表示期間")
    /// チャート表示期間を変更するスライダー
    private let chartDurationSliderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .Palette.text
        label.font = .systemFont(ofSize: 14)
        label.text = "6時間"
        return label
    }()
    
    /// チャート表示期間
    let chartDurationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 12
        slider.tintColor = UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9)
        return slider
    }()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .Palette.main
        closeButton.addTarget(self, action: #selector(didPushCloseButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didPushSaveButton), for: .touchUpInside)
        directionSegmentedControl.addTarget(self,
                                            action: #selector(directionSegmentedControlValueChanged(_:)),
                                            for: .valueChanged)
        
        chartDurationSlider.addTarget(self, action: #selector(chartDurationSliderValueChanged(_:)), for: .valueChanged)
        
        speedUnitSegmentedControl.addTarget(self,
                                            action: #selector(speedUnitSegmentedControlValueChanged(_:)),
                                            for: .valueChanged)
        
        altUnitSegmentedControl.addTarget(self,
                                          action: #selector(altUnitSegmentedControlValueChanged(_:)),
                                          for: .valueChanged)
        
        
        setupFirstValue()
        
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(saveButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 50, height: 40))
        }
        
        setupStackViews()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}

// MARK: - setup sub views

private extension SettingsViewController {
    func setupStackViews() {
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        // 風向き
        stack.addArrangedSubview(directionLabel)
        directionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
        }
        stack.addArrangedSubview(directionSegmentedControl)
        directionSegmentedControl.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 200, height: 36))
        }
        
        // 単位
        stack.addArrangedSubview(unitLabel)
        unitLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
        }
        stack.addArrangedSubview(speedUnitLabel)
        speedUnitLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
        }
        stack.addArrangedSubview(speedUnitSegmentedControl)
        speedUnitSegmentedControl.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 200, height: 36))
        }
        
        stack.addArrangedSubview(altUnitLabel)
        altUnitLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
        }
        stack.addArrangedSubview(altUnitSegmentedControl)
        altUnitSegmentedControl.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 200, height: 36))
        }
        
        // チャート表示期間
        stack.addArrangedSubview(chartDurationTitleLabel)
        chartDurationTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
        }
        stack.addArrangedSubview(chartDurationSliderLabel)
        stack.setCustomSpacing(6, after: (chartDurationSliderLabel))
        stack.addArrangedSubview(chartDurationSlider)
        chartDurationSlider.snp.makeConstraints { make in
            make.width.equalTo(200)
        }
    }
    
    func setupFirstValue() {
        directionSegmentedControl.setIndex(tmpIsTrueNorth ? 0 : 1)
        speedUnitSegmentedControl.setIndex(SpeedUnit.allCases.firstIndex(of: tmpSpeedUnit) ?? 0)
        altUnitSegmentedControl.setIndex(AltUnit.allCases.firstIndex(of: tmpAltUnit) ?? 0)
        chartDurationSlider.value = Float(tmpChartDisplayDuration)
        chartDurationSliderLabel.text = "\(tmpChartDisplayDuration)時間"
    }
}

// MARK: - objc method

private extension SettingsViewController {
    @objc func didPushCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didPushSaveButton() {
        UserDefaults.standard.isTrueNorth = tmpIsTrueNorth
        UserDefaults.standard.chartDisplayDuration = tmpChartDisplayDuration
        UserDefaults.standard.speedUnit = tmpSpeedUnit
        UserDefaults.standard.altUnit = tmpAltUnit
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func directionSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        tmpIsTrueNorth = sender.index == 0
    }
    
    @objc private func chartDurationSliderValueChanged(_ sender: UISlider) {
        let roundValue = roundf(sender.value)
                
        // set round value
        sender.value = roundValue
        let intValue = Int(roundValue)
        chartDurationSliderLabel.text = "\(intValue)時間"
        
        tmpChartDisplayDuration = intValue
    }
    
    @objc private func speedUnitSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        tmpSpeedUnit = SpeedUnit.allCases[sender.index]
    }
    
    @objc private func altUnitSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        tmpAltUnit = AltUnit.allCases[sender.index]
    }
}

private extension SettingsViewController {
    static func createTitleLabel(_ text: String, size: CGFloat = 16) -> UIView {
        let parent = UIView(frame: .zero)
        parent.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        
        let label = UILabel()
        label.textColor = .Palette.text
        label.font = .hiraginoSans(style: .bold, size: size)
        label.text = text
        parent.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        let bottomBorder: UIView = {
            let view = UIView(frame: .zero)
            view.backgroundColor = .lightGray
            return view
        }()
        parent.addSubview(bottomBorder)
        bottomBorder.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return parent
    }
}
