//
//  AuthLogin.swift
//  Eve-Ent
//
//  Created by Metalluxx on 10.01.2020.
//

import UIKit
import Stevia

// MARK: - Block view
public extension AuthView {
    class TextFieldBlock: UIView {
        public let emailTextField = UITextField()
            |= AuthViewDesign.emailTextField
            
        public let passwordTextField = UITextField()
            |= AuthViewDesign.passwordTextField
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            [emailTextField, passwordTextField].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
            }
            
            emailTextField.Height == passwordTextField.Height
            emailTextField.Top == Top + 10
            emailTextField.Left == Left + 10
            emailTextField.Right == Right - 10
            
            emailTextField.Bottom == passwordTextField.Top - 10
            passwordTextField.Bottom == Bottom - 10
            passwordTextField.Left == Left + 10
            passwordTextField.Right == Right - 10
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Main
public class AuthView: UIView {
    typealias Design = AuthViewDesign
    public let blockView = TextFieldBlock()
        |= Design.textFieldBlock
    public let loginBtn = UIButton()
        |= Design.loginButton
    public let titleLabel = UILabel()
        |= Design.titleLabel
    public let subtitleLabel = UILabel()
        |= Design.subtitleLabel
    
    private lazy var keyboardLayout = KeyboardLayoutGuide(view: self, usingSafeArea: true)
    private let gradient = AuthViewDesign.buildGradient()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        for view in [blockView, loginBtn, titleLabel, subtitleLabel] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing))
        )
        
        setupConstraints()
        
        DispatchQueue.main.async {
            self.addAnimatedGradient()
            self.titleLabel.upscaleAnimation(0.5, duration: 1.2, delay: 0.5)
            self.subtitleLabel.upscaleAnimation(0.5, duration: 0.9, delay: 0.8)
        }
    }
    
    func setupConstraints() {
        loginBtn.Height == 30
        loginBtn.Left == keyboardLayout.Left + 10
        loginBtn.Right == keyboardLayout.Right - 10
        loginBtn.Bottom == keyboardLayout.Bottom - 10
        
        blockView.Height >= 100
        blockView.Left == keyboardLayout.Left + 10
        blockView.Right == keyboardLayout.Right - 10
        blockView.Bottom == loginBtn.Top - 10
        
        titleLabel.Top == safeAreaLayoutGuide.Top + 40
        titleLabel.Left == safeAreaLayoutGuide.Left + 30
        titleLabel.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        
        subtitleLabel.Top == titleLabel.Bottom + 10
        subtitleLabel.Left == safeAreaLayoutGuide.Left + 30
        subtitleLabel.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    private func addAnimatedGradient()  {
        gradient.frame = bounds
        gradient.zPosition = -1
        layer.addSublayer(self.gradient)
        gradient.startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UIView {
    func upscaleAnimation(_ percent: CGFloat, duration: TimeInterval = 2, delay: TimeInterval = 0) {
        self.transform = CGAffineTransform(scaleX: percent, y: percent)
        self.alpha = 0
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveEaseOut,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.alpha = 1
            },
            completion: nil)
    }
}

class AuthLoginPreview : UIViewController {
    override func loadView() {
        self.view = AuthView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
