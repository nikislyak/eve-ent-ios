//
//  AuthLogin.swift
//  Eve-Ent
//
//  Created by Metalluxx on 10.01.2020.
//

import UIKit
import Stevia

public extension AuthView {
    class TextFieldBlock: UIView {
        public let emailTextField = with(UITextField(), AuthViewDesign.emailTextField)
            
        public let passwordTextField = with(UITextField(), AuthViewDesign.passwordTextField)
        
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

public class AuthView: UIView {
    typealias Design = AuthViewDesign
    
    public let blockView: TextFieldBlock = with(TextFieldBlock(), Design.textFieldBlock)
    
    public let loginBtn = with(UIButton(), Design.loginButton)

    public let titleLabel = with(UILabel(), Design.titleLabel)
    
    public let subtitleLabel = with(UILabel(), Design.subtitleLabel)
    
    private lazy var keyboardLayout = KeyboardLayoutGuide(view: self, usingSafeArea: true)
    
    private let layersView = UIView()
    private let gradient = Design.buildGradient()
    private let emitter = Design.buildGlareEmitter()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.insertSubview(layersView, at: 0)
        for view in [blockView, loginBtn, titleLabel, subtitleLabel] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.insertSubview(view, at: 1)
        }
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing))
        )
        
        setupConstraints()
        
        DispatchQueue.main.async {
            self.addAnimatedGradient()
            self.addGlareEmitter()
            self.titleLabel.upscaleAnimation(0.5, duration: 1.2, delay: 0.5)
            self.subtitleLabel.upscaleAnimation(0.5, duration: 0.9, delay: 0.8)
        }
    }
    
    private func setupConstraints() {
        layersView.fillContainer()
        
        loginBtn.Height == 40
        loginBtn.Left == keyboardLayout.Left + 10
        loginBtn.Right == keyboardLayout.Right - 10
        loginBtn.Bottom == keyboardLayout.Bottom - 10
        
        blockView.Height == 100
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
    
    private func addGlareEmitter() {
        emitter.frame = bounds
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: 0)
        emitter.emitterSize = bounds.size
        layersView.layer.insertSublayer(emitter, at: 2)
    }
    
    private func addAnimatedGradient()  {
        gradient.frame = bounds
        layersView.layer.insertSublayer(self.gradient, at: 1)
        gradient.startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AuthView: StateDriven {
    struct State: EmptyInitializable {
        var email = ""
    }
    
    func render(_ state: AuthView.State) {
        blockView.emailTextField.text = state.email
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
