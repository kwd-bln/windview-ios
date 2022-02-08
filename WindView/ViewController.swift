//
//  ViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/03.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ログアウト", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .purple
        
        view.addSubview(logoutButton)
        logoutButton.addTarget(self, action: #selector(didPushLogoutButton), for: .touchUpInside)
        logoutButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false, completion: nil)
        }
    }
    
    @objc func didPushLogoutButton() {
        do {
            try Auth.auth().signOut()
            print("ログアウトに成功しました")
        } catch {
            print("ログアウトに失敗しました。")
        }
    }
}

