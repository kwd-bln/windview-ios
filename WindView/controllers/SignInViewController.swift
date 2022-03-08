//
//  LoginViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/04.
//

import UIKit
import SnapKit
import FirebaseAuth
import Firebase
import GoogleSignIn

protocol LoginViewControllerDelegate: AnyObject {
    func loginViewControllerDidDismiss()
}

final class SignInViewController: UIViewController {
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "balloons"))
        let dimView = UIView()
        dimView.backgroundColor = .black.withAlphaComponent(0.2)
        imageView.addSubview(dimView)
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        return stack
    }()
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(frame: .zero)
        tf.placeholder = "メールアドレス"
        tf.keyboardType = .emailAddress
        tf.textContentType = .emailAddress
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
        tf.textColor = .white
        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(frame: .zero)
        tf.placeholder = "パスワード"
        tf.keyboardType = .alphabet
        tf.textContentType = .password
        tf.isSecureTextEntry = true
        tf.textColor = .white
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 160, height: 40))
        }
        button.titleLabel?.font = .hiraginoSans(style: .bold, size: 16)
        button.setTitle("ログイン", for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        button.contentVerticalAlignment = .fill
        button.setBackgroundImage(UIColor.white.withAlphaComponent(0.8).image, for: .normal)
        let grayImage = UIColor.lightGray.withAlphaComponent(0.5).image
        button.setBackgroundImage(grayImage, for: .selected)
        button.setBackgroundImage(grayImage, for: .highlighted)
        return button
    }()
    
    let googleLoginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.titleLabel?.font = .hiraginoSans(style: .bold, size: 16)
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        button.setImage(UIImage(named: "login_logo_google"), for: .normal)
        button.setTitle("Googleでログイン", for: .normal)
        button.contentVerticalAlignment = .fill
        button.backgroundColor = UIColor(hex: "4285f4")
        return button
    }()
    
    private let separetorView = SeparatorView()
    
    private weak var delegate: LoginViewControllerDelegate?
    
    init(delegate: LoginViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        delegate?.loginViewControllerDidDismiss()
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.Palette.main
        isModalInPresentation = true
    
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(stack)
        
        if Util.isPhone {
            stack.snp.makeConstraints { $0.left.right.equalToSuperview() }
        }
        stack.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        stack.addArrangedSubview(emailTextField)
        emailTextField.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-32)
            $0.height.equalTo(40)
        }
        
        stack.addArrangedSubview(passwordTextField)
        passwordTextField.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-32)
            $0.height.equalTo(40)
        }
        
        stack.addArrangedSubview(loginButton)
        loginButton.addTarget(self, action: #selector(didPushLoginButton), for: .touchUpInside)
        stack.setCustomSpacing(32, after: loginButton)
        
        stack.addArrangedSubview(separetorView)
        separetorView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }
        stack.setCustomSpacing(32, after: separetorView)
        
        stack.addArrangedSubview(googleLoginButton)
        googleLoginButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(252).priority(.high)
            $0.left.equalToSuperview().offset(44).priority(.low)
            $0.right.equalToSuperview().offset(-44).priority(.low)
            
        }
        
        googleLoginButton.addTarget(self, action: #selector(didPushGoogleSignInButton), for: .touchUpInside)
    }
    
    @objc private func didPushLoginButton() {
        let email = emailTextField.text ?? ""
        let pass = passwordTextField.text ?? ""
        if email.isEmpty || pass.isEmpty { return }
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] authResult, error in
            if let error = error {
                print("サインインに失敗:", error)
                return
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func didPushGoogleSignInButton() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                print("error in g sign in ", error)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { [unowned self] authResult, error in
                if let error = error {
                    let authError = error as NSError
                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        print("second factor required")
                    } else {
                        print(error.localizedDescription)
                    }
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
            
            
        }
    }
}

private class SeparatorView: UIView {
    private static let orLabelTextPhone: String = "メールアドレス以外での\nログインはこちら"
    private static let orLabelTextPad: String = "メールアドレス以外でのログインはこちら"
    
    convenience init() {
        self.init(frame: .zero)
        let label = addLabel()
        label.sizeToFit()
        let left = addLine()
        let right = addLine()
        
        label.snp.makeConstraints {
            $0.centerX.top.bottom.equalToSuperview()
        }
        
        left.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.centerY.left.equalToSuperview()
            $0.right.equalTo(label.snp.left).offset(-14).priority(.low)
        }
        
        right.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.centerY.right.equalToSuperview()
            $0.left.equalTo(label.snp.right).offset(14).priority(.low)
        }
    }
    
    private func addLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.attributedText = .init(
            string: Util.isPhone ? SeparatorView.orLabelTextPhone : SeparatorView.orLabelTextPad,
            font: .hiraginoSans(style: .light, size: 12),
            lineSpacing: Util.isPhone ? 12 : 8,
            alignment: .center
        )
        addSubview(label)
        return label
    }
    
    private func addLine() -> UIView {
        let line = UIView()
        line.backgroundColor = .white
        addSubview(line)
        return line
    }
}
