//
//  AuthLogin.swift
//  Eve-Ent
//
//  Created by Metalluxx on 10.01.2020.
//

import UIKit
import Stevia
import Overture
import Library

private func preparePlaceholder(text: String) -> NSAttributedString {
    .init(
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
            |> \.attributedPlaceholder .~ preparePlaceholder(text: L10n.Authorization.EmailTextField.placeholder)
        
        
        public let passwordTextField = UITextField()
            |> \.textColor .~ .white
            |> \.textContentType .~ .password
            |> \.keyboardAppearance .~ .dark
            |> \.autocapitalizationType .~ .none
            |> \.isSecureTextEntry .~ true
            |> \.attributedPlaceholder .~ preparePlaceholder(text: L10n.Authorization.PasswordTextField.placeholder)
        
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
        [
            blockView.view.emailTextField,
            blockView.view.passwordTextField
        ]
        .first(where: ^\.isFirstResponder)
    }
    
    let scrollView = UIScrollView()
        |> \.alwaysBounceVertical .~ true
        |> \.keyboardDismissMode .~ .interactive
    
    let stackView = UIStackView()
        |> \.spacing .~ 10
        |> \.axis .~ .vertical
        |> \.isLayoutMarginsRelativeArrangement .~ true
        |> \.layoutMargins .~ UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    public let blockView =
        VisualEffectContainer(view: TextFieldBlock(), effect: UIBlurEffect(style: .systemChromeMaterialDark))
            |> \.view.layer.cornerRadius .~ 5
            |> \.view.layer.masksToBounds .~ true
    
    public let loginBtn =
        VisualEffectContainer(view: UIButton(), effect: UIBlurEffect(style: .systemChromeMaterialDark))
            |> \.view.layer.cornerRadius .~ 5
            |> \.view.layer.masksToBounds .~ true
            |> sideEffect(^\.view >>> sideEffect(flip(UIButton.setTitle)(L10n.Authorization.SignInButton.title, .normal)))

    
    private lazy var keyboardLayout = KeyboardLayoutGuide(view: self, usingSafeArea: true)
    
    private let layersView = UIView()
    private let gradient = Design.buildGradient()
    private let emitter = Design.buildGlareEmitter()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white

        sv(layersView, scrollView)
        
        scrollView.sv(
            stackView.with(
                blockView,
                loginBtn
            )
        )
        
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
        scrollView.top(0).left(0).right(0).bottom(toSafeAreaOf: self, 0)
        
        stackView.centerInContainer()
        stackView.Width == scrollView.Width
        
        loginBtn.Height == 40
        blockView.Height == 100
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
    public struct State: EmptyInitializable, Equatable {
        var email = ""
        var password = ""
        
        public init() {}
    }
    
    public func render(_ state: State) {
        blockView.view.emailTextField.text = state.email
        blockView.view.passwordTextField.text = state.password
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
