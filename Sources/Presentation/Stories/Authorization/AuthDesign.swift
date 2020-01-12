//
//  AuthDesign.swift
//  Eve-Ent
//
//  Created by Metalluxx on 12.01.2020.
//

import UIKit


public enum AuthViewDesign {
    // MARK: Label
    public static func titleLabel(_ label: UILabel) {
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 70, weight: .semibold)
        label.text = "Title"
    }
    
    public static func subtitleLabel(_ label: UILabel) {
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 25, weight: .ultraLight)
        label.text = "Subtitle"
    }
    
    // MARK: Gradient
    public static func buildGradient() -> AnimatedGradient {
        let colors = [
            AnimatedGradient.ColorBox(
                startPoint: UIColor(red: 97/255, green: 23/255, blue: 232/255, alpha: 1),
                endPoint: UIColor(red: 9/255, green: 113/255, blue: 222/255, alpha: 1)
            ),
            AnimatedGradient.ColorBox(
                startPoint: UIColor(red: 9/255, green: 113/255, blue: 222/255, alpha: 1),
                endPoint: UIColor(red: 200/255, green: 120/255, blue: 70/255, alpha: 1)
            ),
            AnimatedGradient.ColorBox(
                startPoint: UIColor(red: 200/255, green: 120/255, blue: 70/255, alpha: 1),
                endPoint: UIColor(red: 70/255 , green: 110/255, blue: 130/255, alpha: 1)
            ),
            AnimatedGradient.ColorBox(
                startPoint: UIColor(red: 70/255 , green: 110/255, blue: 130/255, alpha: 1),
                endPoint: UIColor(red: 97/255, green: 23/255, blue: 232/255, alpha: 1)
            ),
        ]
        return AnimatedGradient(
            colors: colors,
            duration: 5,
            startBox: AnimatedGradient.ColorBox(startPoint: .black, endPoint: .black)
        )
    }
    
    // MARK: UIView
    private static func roundedRect(_ view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    private static func blockBackground(_ view: UIView) {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }

    // MARK: TextField
    public static func textFieldBlock(_ view: UIView) {
        roundedRect(view)
        blockBackground(view)
    }
    
    private static func configureTextField(textField tf: UITextField, text: String) {
        tf.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor : UIColor.lightGray]
        )
        tf.textColor = .white
        tf.keyboardAppearance = .dark
    }
 
    public static func emailTextField(_ tf: UITextField) {
        configureTextField(
            textField: tf,
            text: "Email"
        )
        tf.autocapitalizationType = .none
        tf.textContentType = .emailAddress
    }
    
    public static func passwordTextField(_ tf: UITextField) {
        configureTextField(
            textField: tf,
            text: "Password"
        )
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.textContentType = .password
    }
    
    // MARK: Button
    public static func loginButton(_ btn: UIButton) {
        roundedRect(btn)
        blockBackground(btn)
        btn.setTitle("Auth", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.setTitleColor(.white, for: .highlighted)
    }
}
