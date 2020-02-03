//
//  VisualEffectContainer.swift
//  Eve-Ent
//
//  Created by Metalluxx on 12.01.2020.
//

import UIKit

public class VisualEffectContainer<View: UIView>: UIVisualEffectView {
    public weak var view: View!
    
    public init(view: View, effect: UIVisualEffect?) {
        self.view = view
        super.init(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
