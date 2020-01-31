//
//  AuthDesign.swift
//  Eve-Ent
//
//  Created by Metalluxx on 12.01.2020.
//

import UIKit

public enum AuthViewDesign {
    private static func roundedRect(_ view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    private static func configureTextField(textField tf: UITextField, text: String) {
        tf.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor : UIColor.lightGray]
        )
        tf.textColor = .white
        tf.keyboardAppearance = .dark
    }
    
    public static func titleLabel(_ label: UILabel) {

    }
    
    public static func subtitleLabel(_ label: UILabel) {
        label.numberOfLines = 0
        label.textColor = UIColor.black.withAlphaComponent(0.95)
        label.font = .systemFont(ofSize: 35, weight: .ultraLight)
        label.text = "Subtitle"
    }
    
    public static func buildGlareEmitter() -> CAEmitterLayer {
        let glareLayer = GlareLayer()
        glareLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        glareLayer.setNeedsDisplay()
        
        let image: CGImage? = {
            UIGraphicsBeginImageContext(glareLayer.bounds.size);
            glareLayer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            return image?.cgImage
        }()
        
        let cell = CAEmitterCell()
        cell.contents = image
        cell.emissionRange = .pi
        cell.lifetime = 15
        cell.birthRate = 1.5
        cell.scale = 0.3
        cell.scaleRange = 1
        cell.velocity = 0
        cell.velocityRange = 0
        cell.spin = 0
        cell.spinRange = 0
        cell.yAcceleration = 15.0
        cell.xAcceleration = 2.0
        
        let emitter = CAEmitterLayer()
        emitter.renderMode = .additive
        emitter.emitterShape = .line
        emitter.emitterCells = [cell]
        return emitter
    }
    
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
    

    public static func textFieldBlock(_ view: AuthView.TextFieldBlock) {
        roundedRect(view)
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
    
    public static func loginButton(_ btn: UIButton) {
        roundedRect(btn)
        btn.setTitle("Auth", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.setTitleColor(.white, for: .highlighted)
    }
}
