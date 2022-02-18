//
//  HomeViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    // MARK: PageViewController系
    
    let pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll,
                                       navigationOrientation: .horizontal,
                                       options: nil)
        pvc.view.backgroundColor = .clear
        return pvc
    }()
    
    private var currentPageIndex: Int = 0
    
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
        viewModel.inputs.loadView()
        
        Driver.combineLatest(
            viewModel.outputs.sondeDataList,
            viewModel.outputs.chartSize,
            viewModel.outputs.isDistFrom
        ).drive { [weak self] sondeDataList, csize, isDistFrom in
            if sondeDataList.count == 0 { return }
            self?.distanceChartViewController.drawChart(by: sondeDataList, with: csize, isTo: !isDistFrom)
        }.disposed(by: disposeBag)
        
        viewModel.outputs.sondeDataList.drive { [weak self] sondeDataList in
            self?.speedChartViewController.viewModel.inputs.updateSondeDataList(sondeDataList)
            self?.colorLayerTableViewController.set(sondeDataList)
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

// MARK: - UI

private extension HomeViewController {
    func setupSubviews() {
        setupPVC()
        setupMenuStackView()
        
        view.addSubview(bottomControlView)
        bottomControlView.snp.makeConstraints { make in
            make.top.equalTo(pageViewController.view.snp.bottom)
            make.left.right.bottom.equalToSuperview()
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
            $0.top.equalTo(safeAreaGuide).offset(60)
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
        menuTitles.forEach { menuTitle in
            let menuButton = UIButton.createMenuButton(text: menuTitle, textColor: .Palette.text)
            menuStackView.addArrangedSubview(menuButton)
            menuButton.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
            menuButtons.append(menuButton)
            
            let hiddenButton = UIButton.createMenuButton(text: menuTitle, textColor: .Palette.main)
            hiddenMenuStackView.addArrangedSubview(hiddenButton)
            hiddenButton.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
        }
        
        view.addSubview(menuStackView)
        menuStackView.snp.makeConstraints { make in
            make.bottom.equalTo(pageViewController.view.snp.top)
            make.left.greaterThanOrEqualToSuperview().priority(.low)
            make.right.lessThanOrEqualToSuperview().priority(.low)
            make.centerX.equalToSuperview().priority(.medium)
        }
        
        view.addSubview(hiddenMenuStackView)
        hiddenMenuStackView.snp.makeConstraints { make in
            make.bottom.equalTo(pageViewController.view.snp.top)
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
}

// MARK: - show history and setting

extension HomeViewController {
    func showHistoryViewController() {
        let historyViewController = HistoryViewController()
        historyViewController.presentationController?.delegate = self
        present(historyViewController, animated: true, completion: nil)
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
        
        let leftRatio = currentIndex < moveToIndex ? 1 - ratio : ratio
        let currentX = currentMenuButton.frame.minX * leftRatio + currentMenuButton.frame.maxX * (1 - leftRatio)
        let moveToX = moveToButton.frame.minX * leftRatio + moveToButton.frame.maxX * (1 - leftRatio)
        let x = min(currentX, moveToX)
        let width = abs(moveToX - currentX)
        
        let rect: CGRect = .init(x: x, y: currentMenuButton.frame.minY, width: width, height: currentMenuButton.frame.height)
        
        let maskPath = UIBezierPath(roundedRect: rect, cornerRadius: currentMenuButton.frame.height / 2)
        currentHole.path = maskPath.cgPath
    }
}

