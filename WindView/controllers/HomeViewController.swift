//
//  HomeViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

final class HomeViewController: UIViewController {
    // orientaion
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    // MARK: PageViewController系
    
    let pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll,
                                       navigationOrientation: .horizontal,
                                       options: nil)
        pvc.view.backgroundColor = .clear
        return pvc
    }()
    
    private var currentPageIndex: Int = 0
    private var currentMoveToIndex: Int? = nil
    
    let childVCList: [(menuTitle: String, vc: UIViewController)]
    
    private var childControllers: [UIViewController] {
        childVCList.map { $0.vc }
    }
    
    private var distanceChartViewController: DistanceChartViewController {
        childControllers[0] as! DistanceChartViewController
    }
    
    private var speedChartViewController: SpeedChartViewController {
        childControllers[1] as! SpeedChartViewController
    }
    
    private var colorLayerTableViewController: ColorLayerTableViewController {
        childControllers[2] as! ColorLayerTableViewController
    }
    
    let viewModel: HomeViewModelType
    var firstOpen: Bool = true
    
    // MARK: views
    
    private let navigationHeader: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    private let smallTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .hiraginoSans(style: .extraBold, size: 13)
        label.textColor = .Palette.text
        return label
    }()
    
    private let smallSubTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .hiraginoSans(style: .light, size: 12)
        label.textColor = .Palette.text
        return label
    }()
    
    /// menuButtonを置くためのStackView
    var menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    /// holeの中だけ見えるScrollView
    private let hiddenMenuStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        stack.backgroundColor = .Palette.text
        return stack
    }()
    
    /// 選ばれているmenuを示すmask
    var currentHole: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.white.cgColor
        return maskLayer
    }()
    
    var menuButtons: [UIButton] = []
    
    var safeAreaGuide: UILayoutGuide {
        view.safeAreaLayoutGuide
    }
    
    let bottomControlView = BottomControlView(frame: .zero)
    
    // MARK: その他
    /// pagingVCがアニメーション中かどうか
    var isVCAnimating: Bool = false {
        didSet {
            pageViewController.view.isUserInteractionEnabled = !isVCAnimating
        }
    }
    
    let disposeBag = DisposeBag()
    
    init(viewModel: HomeViewModelType = HomeViewModel()) {
        self.viewModel = viewModel
        self.childVCList = [
            ("DistanceChart", DistanceChartViewController()),
            ("SpeedChart", SpeedChartViewController()),
            ("ColorTable", ColorLayerTableViewController())
        ]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .Palette.main
        
        setupSubviews()
        setupBindings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !viewModel.outputs.isLoggedIn {
            DispatchQueue.main.async { [weak self] in
                self?.showLoginViewController()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for view in self.pageViewController.view.subviews {
            if view is UIScrollView {
                (view as? UIScrollView)!.delaysContentTouches = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstOpen, menuButtons[1].frame.origin.x > 0 {
            updateCurrentHole(currentIndex: 0, moveToIndex: 1, ratio: 0)
            firstOpen = false
        }
    }
}

// MARK: - DataBinding

private extension HomeViewController {
    func setupBindings() {
        viewModel.inputs.loadView()
        HUD.show(.progress, onView: view)
        
        Driver.combineLatest(
            viewModel.outputs.sondeDataList,
            viewModel.outputs.chartSize,
            viewModel.outputs.isDistFrom,
            viewModel.outputs.displayDataSettings
        ).drive { [weak self] sondeDataList, csize, isDistFrom, displayDataSettings in
            if sondeDataList.count == 0 { return }
            
            self?.updateLabels(date: sondeDataList.first?.updatedAt.dateValue(),
                         autooUpdate: self?.viewModel.outputs.autoUpdateData == true)
            
            HUD.hide(afterDelay: 0.5)
            self?.distanceChartViewController.drawChart(by: sondeDataList,
                                                        with: csize,
                                                        isTo: !isDistFrom,
                                                        useTN: displayDataSettings.isTrueNorth)
        }.disposed(by: disposeBag)
        
        Driver.combineLatest(
            viewModel.outputs.sondeDataList,
            viewModel.outputs.displayDataSettings
        ).drive { [weak self] sondeDataList, displayDataSettings in
            self?.speedChartViewController.viewModel.inputs.updateSondeDataList(sondeDataList)
            self?.speedChartViewController.viewModel.inputs.updateUseTrueNorth(displayDataSettings.isTrueNorth)
            self?.speedChartViewController.viewModel.inputs.updateSpeedUnit(displayDataSettings.speedUnit)
            self?.colorLayerTableViewController.set(sondeDataList,
                                                    useTN: displayDataSettings.isTrueNorth,
                                                    speedUnit: displayDataSettings.speedUnit,
                                                    altUnit: displayDataSettings.altUnit)
        }.disposed(by: disposeBag)
        
        distanceChartViewController
            .zoomButtonTap
            .bind(to: viewModel.inputs.zoomButtonTap)
            .disposed(by: disposeBag)
        
        distanceChartViewController
            .isFromSegmentSelectedRelay
            .bind(to: viewModel.inputs.distIsFromSegment)
            .disposed(by: disposeBag)
        
        bottomControlView.historyButton.button.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.showHistoryViewController()
            })
            .disposed(by: disposeBag)
        
        bottomControlView.settingView.button.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.showSettingsViewController()
            })
            .disposed(by: disposeBag)
    }
    
    func updateLabels(date: Date?, autooUpdate: Bool) {
        if let date = date {
            let dateText = DateUtil.dateText(from: date)
            smallTitle.text = dateText
        }
        
        if viewModel.outputs.autoUpdateData {
            smallSubTitle.text = "[更新中]"
            smallSubTitle.textColor = .red
        } else {
            smallSubTitle.text = "[停止中]"
            smallSubTitle.textColor = .Palette.text
        }
    }
}


// MARK: - UI

private extension HomeViewController {
    func setupSubviews() {
        setupHeader()
        setupMenuStackView()
        setupPVC()
        
        view.addSubview(bottomControlView)
        bottomControlView.snp.makeConstraints { make in
            make.top.equalTo(pageViewController.view.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func setupHeader() {
        view.addSubview(navigationHeader)
        navigationHeader.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaGuide.snp.top).offset(4)
            $0.bottom.equalTo(safeAreaGuide.snp.top).offset(40)
        }
        
        navigationHeader.addSubview(smallTitle)
        smallTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-20)
            $0.centerY.equalTo(navigationHeader)
        }
        
        navigationHeader.addSubview(smallSubTitle)
        smallSubTitle.snp.makeConstraints { make in
            make.left.equalTo(smallTitle.snp.right).offset(16)
            make.centerY.equalTo(navigationHeader)
        }
    }
    
    func setupPVC() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.subviews
            .filter { $0 is UIScrollView }
            .forEach {
                ($0 as? UIScrollView)?.delegate = self
            }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(menuStackView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaGuide).offset(-72)
        }
        
        pageViewController.setViewControllers([childControllers[0]],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
    }
    
    func setupMenuStackView() {
        hiddenMenuStackView.layer.mask = currentHole
        menuTitles.enumerated().forEach { index, menuTitle in
            let menuButton = UIButton.createMenuButton(text: menuTitle, textColor: .Palette.text)
            menuStackView.addArrangedSubview(menuButton)
            menuButton.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
            menuButtons.append(menuButton)
            
            let hiddenButton = UIButton.createMenuButton(text: menuTitle, textColor: .Palette.main)
            hiddenButton.tag = index
            hiddenButton.addTarget(self, action: #selector(didPushMenuItem(_:)), for: .touchUpInside)
            hiddenMenuStackView.addArrangedSubview(hiddenButton)
            hiddenButton.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
        }
        
        view.addSubview(menuStackView)
        menuStackView.snp.makeConstraints { make in
            make.top.equalTo(navigationHeader.snp.bottom)
            make.left.greaterThanOrEqualToSuperview().priority(.low)
            make.right.lessThanOrEqualToSuperview().priority(.low)
            make.centerX.equalToSuperview().priority(.medium)
        }
        
        view.addSubview(hiddenMenuStackView)
        hiddenMenuStackView.snp.makeConstraints { make in
            make.top.equalTo(navigationHeader.snp.bottom)
            make.left.greaterThanOrEqualToSuperview().priority(.low)
            make.right.lessThanOrEqualToSuperview().priority(.low)
            make.centerX.equalToSuperview().priority(.medium)
        }
    }
}

// MARK: childs

extension HomeViewController {
    ///
    var menuTitles: [String] {
        childVCList.map { $0.menuTitle }
    }
}

// MARK: - show history and setting

extension HomeViewController {
    func showHistoryViewController() {
        let historyViewController = HistoryViewController()
        historyViewController.presentationController?.delegate = self
        present(historyViewController, animated: true, completion: nil)
    }
    
    func showSettingsViewController() {
        let settingsViewController = SettingsViewController(delegate: self)
        present(settingsViewController, animated: true, completion: nil)
    }
    
    func showLoginViewController() {
        let loginViewController = SignInViewController(delegate: self)
        present(loginViewController, animated: true, completion: nil)
    }
}


// MARK: - UIPageViewControllerDataSource

extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = childControllers.firstIndex(of: viewController), index != 0 {
            return childControllers[index - 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = childControllers.firstIndex(of: viewController), index < childControllers.count - 1 {
            return childControllers[index + 1]
        } else {
            return nil
        }
    }
    
    @objc private func didPushMenuItem(_ sender: UIButton) {
        if isVCAnimating { return }
        updatePageVC(to: sender.tag)
    }
    
    private func updatePageVC(to index: Int) {
        if currentPageIndex == index { return }
        let targetVC = childControllers[index]
        if pageViewController.viewControllers?.first == targetVC { return }
        isVCAnimating = true
        currentMoveToIndex = index
        pageViewController.setViewControllers([targetVC],
                                              direction: index > currentPageIndex ? .forward : .reverse,
                                              animated: true,
                                              completion: { [weak self] _ in
            self?.isVCAnimating = false
            self?.currentPageIndex = index
            self?.currentMoveToIndex = nil
        })
    }
    
    private func updateCurrentHole(from index: Int, to target: Int) {
        let currentMenuButton = menuButtons[index]
        let moveToButton = menuButtons[target]
        let anim = CABasicAnimation(keyPath:"path")
        anim.fromValue = UIBezierPath(roundedRect: currentMenuButton.frame, cornerRadius: currentMenuButton.frame.height / 2)
        anim.toValue = UIBezierPath(roundedRect: moveToButton.frame, cornerRadius: moveToButton.frame.height / 2)
        anim.duration = 0.3
        currentHole.add(anim, forKey: nil)
    }
}

// MARK: - UIPageViewControllerDelegate

extension HomeViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating _: Bool,
                            previousViewControllers _: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let viewController: UIViewController = pageViewController.viewControllers?.last {
            guard let index = childControllers.firstIndex(of: viewController) else { return }
            if completed {
                currentPageIndex = index
            }
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.inputs.reAppearView()
    }
}

// MARK: - UIScrollViewDelegate

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // viewControllerがsetViewControllersによってアニメーション中には以下を呼ばない。
        let parentWidth = view.frame.width
        let leftRightJug = parentWidth - scrollView.contentOffset.x
        if leftRightJug == 0 {
            return
        }
        
        if isVCAnimating {
            guard let currentMoveToIndex = currentMoveToIndex else { return }
            let moveRatio = abs(leftRightJug) / parentWidth
            updateCurrentHole(currentIndex: currentPageIndex, moveToIndex: currentMoveToIndex, ratio: moveRatio)
            return
        }

        let moveToIndex = leftRightJug > 0 ? currentPageIndex - 1 : currentPageIndex + 1

        // スクロール量に合わせてメニュータブの位置をコントロールする。
        if moveToIndex >= 0, moveToIndex <= childControllers.count - 1 {
            let moveRatio = abs(leftRightJug) / parentWidth
            updateCurrentHole(currentIndex: currentPageIndex, moveToIndex: moveToIndex, ratio: moveRatio)
        }
    }
    
    private func updateCurrentHole(currentIndex: Int, moveToIndex: Int, ratio: CGFloat) {
        let currentMenuButton = menuButtons[currentIndex]
        let moveToButton = menuButtons[moveToIndex]
        let minX = moveToButton.frame.minX * ratio + currentMenuButton.frame.minX * (1 - ratio)
        let maxX = moveToButton.frame.maxX * ratio + currentMenuButton.frame.maxX * (1 - ratio)
        
        let rect: CGRect = .init(x: minX, y: currentMenuButton.frame.minY, width: maxX - minX, height: currentMenuButton.frame.height)
        
        let maskPath = UIBezierPath(roundedRect: rect, cornerRadius: currentMenuButton.frame.height / 2)
        currentHole.path = maskPath.cgPath
    }
}

extension HomeViewController: LoginViewControllerDelegate {
    func loginViewControllerDidDismiss() {
        viewModel.inputs.finishLogin()
    }
}

extension HomeViewController: SettingsViewControllerDelegate {
    func settingsViewControllerDidDismiss(logouted: Bool) {
        if logouted {
            viewModel.inputs.logout()
            DispatchQueue.main.async { [weak self] in
                self?.showLoginViewController()
            }
        } else {
            viewModel.inputs.reAppearView()
        }
    }
}
