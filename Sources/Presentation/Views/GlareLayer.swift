//
//  GlareLayer.swift
//  Eve-Ent
//
//  Created by Metalluxx on 13.01.2020.
//

import UIKit

public class GlareLayer: CALayer {
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    public override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        let radius = min(self.bounds.height / 2, self.bounds.width / 2)
        let centerPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let path = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: false
        )
        ctx.addPath(path.cgPath)
        ctx.clip()
        
        let colors = [UIColor.white.withAlphaComponent(0.8), UIColor.darkGray.withAlphaComponent(0.4)]
            .map { $0.cgColor } as CFArray
        
        let cicleGradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)!
        ctx.drawLinearGradient(
            cicleGradient,
            start: CGPoint(x: 0, y: self.bounds.height),
            end: CGPoint(x: self.bounds.width, y: 0),
            options: .init()
        )
        ctx.setShadow(
            offset: CGSize(width: self.bounds.width, height: self.bounds.height),
            blur: 1,
            color: UIColor.black.cgColor
        )
        UIGraphicsPopContext()
    }
}
