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
    
    // MARK: views
    
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
            .fromButtonTap
            .bind(to: viewModel.inputs.distFromButtonTap)
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
}

// MARK: - UI

private extension HomeViewController {
    func setupSubviews() {
        setupPVC()
        view.addSubview(bottomControlView)
        bottomControlView.snp.makeConstraints { make in
            make.top.equalTo(pageViewController.view.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func setupPVC() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(safeAreaGuide).offset(45)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaGuide).offset(-60)
        }
        
        pageViewController.setViewControllers([childControllers[2]],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
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

extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.inputs.reAppearView()
    }
}
