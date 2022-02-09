//
//  HomeViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import UIKit

final class HomeViewController: UIViewController {
    
    let pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll,
                                       navigationOrientation: .horizontal,
                                       options: nil)
        pvc.view.backgroundColor = .white
        return pvc
    }()
    
    let childVCList: [(menuTitle: String, vc: UIViewController)] = [("first", UIViewController(nibName: nil, bundle: nil))]
    
    private var childControllers: [UIViewController] {
        childVCList.map { $0.vc }
    }
    
    let viewModel: HomeViewModelType
    
    var safeAreaGuide: UILayoutGuide {
        view.safeAreaLayoutGuide
    }
    
    init(viewModel: HomeViewModelType = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .blue
        setupPVC()
    }
    
    private func setupPVC() {
//        pageViewController.dataSource = self
//        pageViewController.delegate = self
        
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
