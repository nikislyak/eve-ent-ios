//
//  AuthLogin.swift
//  Eve-Ent
//
//  Created by Metalluxx on 10.01.2020.
//

import UIKit
import Stevia
import Overture

fileprivate func preparePlaceholder(text: String) -> NSAttributedString {
    return NSAttributedString(
        string: text,
        attributes: [.foregroundColor : UIColor.lightGray]
    )
}

public extension AuthView {
    class TextFieldBlock: UIView {
        public let emailTextField = UITextField()
            |> \.textColor .~ .white
            |> \.textContentType .~ .emailAddress
            |> \.keyboardAppearance .~ .dark
            |> \.autocapitalizationType .~ .none
            |> \.attributedPlaceholder .~ preparePlaceholder(text: "Email")
        
        
        public let passwordTextField = UITextField()
            |> \.textColor .~ .white
            |> \.textContentType .~ .password
            |> \.keyboardAppearance .~ .dark
            |> \.autocapitalizationType .~ .none
            |> \.isSecureTextEntry .~ true
            |> \.attributedPlaceholder .~ preparePlaceholder(text: "Password")
        
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
    
    var activeTextInput: UIView? {
        [blockView.view.emailTextField, blockView.view.emailTextField].first(where: ^\.isFirstResponder)
    }
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    public let blockView =
        VisualEffectContainer(view: TextFieldBlock(), effect: UIBlurEffect(style: .systemChromeMaterialDark))
            |> \.view.layer.cornerRadius .~ 5
            |> \.view.layer.masksToBounds .~ true
    
    public let loginBtn =
        VisualEffectContainer(view: UIButton(), effect: UIBlurEffect(style: .systemChromeMaterialDark))
            |> \.view.layer.cornerRadius .~ 5
            |> \.view.layer.masksToBounds .~ true
            |> sideEffect(^\.view >>> sideEffect(flip(UIButton.setTitle)("String", .normal)))

    
    private lazy var keyboardLayout = KeyboardLayoutGuide(view: self, usingSafeArea: true)
    
    private let layersView = UIView()
    private let gradient = Design.buildGradient()
    private let emitter = Design.buildGlareEmitter()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white

        self.insertSubview(layersView, at: 0)
        self.insertSubview(scrollView, at: 1)
        scrollView.insertSubview(stackView, at: 0)
        stackView.addArrangedSubview(blockView)
        stackView.addArrangedSubview(loginBtn)
        stackView.arra
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing))
        )
        
        setupConstraints()
        
        DispatchQueue.main.async {
            self.addAnimatedGradient()
            self.addGlareEmitter()
        }
    }
    
    private func setupConstraints() {
        layersView.fillContainer()
        scrollView.fillContainer()
        
        loginBtn.Height == 40
        loginBtn.Left == keyboardLayout.Left + 10
        loginBtn.Right == keyboardLayout.Right - 10
        loginBtn.Bottom == keyboardLayout.Bottom - 10
        
        blockView.Height == 100
        blockView.Left == keyboardLayout.Left + 10
        blockView.Right == keyboardLayout.Right - 10
        blockView.Bottom == loginBtn.Top - 10
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
        blockView.view.emailTextField.text = state.email
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
