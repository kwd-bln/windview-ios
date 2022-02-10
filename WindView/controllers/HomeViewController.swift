//
//  HomeViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import UIKit

final class HomeViewController: UIViewController {
    // MARK: PageViewController系
    
    let pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll,
                                       navigationOrientation: .horizontal,
                                       options: nil)
        pvc.view.backgroundColor = .white
        return pvc
    }()
    
    private var currentPageIndex: Int = 0
    
    let childVCList: [(menuTitle: String, vc: UIViewController)]
    
    private var childControllers: [UIViewController] {
        childVCList.map { $0.vc }
    }
    
    
    let viewModel: HomeViewModelType
    
    // MARK: views
    
    let distanceChartView = DistanceChartView()
    
    var safeAreaGuide: UILayoutGuide {
        view.safeAreaLayoutGuide
    }
    
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
        view.backgroundColor = .blue
        setupPVC()
        
        view.addSubview(distanceChartView)
        distanceChartView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.width.equalTo(distanceChartView.snp.height)
        }
    }
    
    private func setupPVC() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(safeAreaGuide).offset(45)
            $0.left.right.bottom.equalToSuperview()
        }
        
        pageViewController.setViewControllers([childControllers[0]],
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

