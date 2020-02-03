//
//  AnimatedGradient.swift
//  Eve-Ent
//
//  Created by Metalluxx on 12.01.2020.
//

import UIKit

public extension AnimatedGradient {
    struct ColorBox {
        public let startPoint: UIColor
        public let endPoint: UIColor
        
        var cgColor: [CGColor] {
            return [startPoint.cgColor, endPoint.cgColor]
        }
    }

    private struct State {
        let colors: [ColorBox]
        let duration: TimeInterval
        var currentIndex: Int
        
        init(colors: [ColorBox], duration: TimeInterval, currentIndex: Int) {
            self.colors = colors
            self.duration = duration
            self.currentIndex = currentIndex
        }
        
        var currentColorBox: ColorBox {
            return colors[currentIndex]
        }
        
        @discardableResult mutating func incrementIndex() -> State {
            currentIndex = (currentIndex == colors.count - 1) ? 0 : (currentIndex + 1)
            return self
        }
    }
}

final public class AnimatedGradient: CALayer {
    // MARK: Vars
    private var startBox: ColorBox?
    private var state: State

    // MARK: Init
    public override init(layer: Any) {
        let layer = layer as! AnimatedGradient
        self.state = layer.state
        self.startBox = layer.startBox
        super.init(layer: layer)
    }
    
    public init(
        colors: [ColorBox],
        duration: TimeInterval,
        startBox: ColorBox? = nil
    ) {
        self.state = State(
            colors: colors,
            duration: duration,
            currentIndex: 0
        )
        
        self.startBox = startBox
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public functions
    public func startAnimation() {
        guard state.colors.count > 0 else { return }
        
        if let startBox = startBox {
            executeInitialColorAnimation(startBox: startBox)
        } else {
            executeAnimation()
        }
    }
        
    public func stopAnimation() {
        removeAllAnimations()
    }
    
    // MARK: Private logic
    private func executeInitialColorAnimation(startBox: ColorBox) {
        let newLayer = getGradientLayer(for: startBox)
        newLayer.frame = self.bounds
        self.addSublayer(newLayer)
        insertAnimation(in: newLayer, for: state) { [weak self] state in
            self?.startBox = nil
            self?.executeAnimation()
        }
    }
    
    private func executeAnimation() {
        let newLayer = getGradientLayer(for: state.currentColorBox)
        newLayer.frame = self.bounds
        self.addSublayer(newLayer)
        insertAnimation(in: newLayer, for: state.incrementIndex()) { [weak self] state in
            self?.executeAnimation()
        }
    }

    private func insertAnimation(
        in layer: CAGradientLayer,
        for state: State,
        completionHandler: @escaping (State) -> Void
    ) {
        CATransaction.begin()
        
        let animation = CABasicAnimation(keyPath: "colors")
        
        animation.duration = state.duration
        animation.toValue = state.currentColorBox.cgColor
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        CATransaction.setCompletionBlock {
            layer.removeFromSuperlayer()
            
            completionHandler(state)
        }
        
        layer.add(animation, forKey: "colorChange")
        
        CATransaction.commit()
    }
        
    private func getGradientLayer(for colorBox: ColorBox) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = colorBox.cgColor
        return gradient
    }
}
