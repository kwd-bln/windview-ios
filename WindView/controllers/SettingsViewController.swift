//
//  SettingsViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/19.
//

import UIKit
import BetterSegmentedControl

final class SettingsViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .hiraginoSans(style: .bold, size: 13)
        label.textColor = .Palette.text
        label.text = "設定"
        return label
    }()
    
    private let closeButton: UIButton = CloseButton(frame: .zero)
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - views
    
    private let directionLabel = createTitleLabel("方角")
    /// 磁北・真北
    private let directionSegmentedControl = BetterSegmentedControl(
        frame: .zero,
        segments: LabelSegment.segments(withTitles: ["磁北", "真北"],
                                        normalTextColor: UIColor(red: 0.15, green: 0.39, blue: 0.96, alpha: 0.9),
                                        selectedTextColor: UIColor(red: 0.16, green: 0.40, blue: 0.96, alpha: 1.00)),
        options: [.backgroundColor(UIColor(red: 0.6, green: 0.7, blue: 0.98, alpha: 1)),
                  .indicatorViewBackgroundColor(.white),
                  .cornerRadius(18)]
    )
    
    private let chartDurationTitleLabel = createTitleLabel("チャート表示期間")
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
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
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
        
        stack.addArrangedSubview(directionLabel)
        directionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
        }
        stack.addArrangedSubview(directionSegmentedControl)
        directionSegmentedControl.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        
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
}

// MARK: - objc method

private extension SettingsViewController {
    @objc func didPushCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}

private extension SettingsViewController {
    static func createTitleLabel(_ text: String) -> UIView {
        let parent = UIView(frame: .zero)
        parent.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        
        let label = UILabel()
        label.textColor = .Palette.text
        label.font = .hiraginoSans(style: .bold, size: 16)
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
