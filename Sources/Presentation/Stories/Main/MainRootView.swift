//
//  MainRootView.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation
import UIKit
import Library
import Stevia

public class MainRootView: BaseView {
    override func setup() {
        super.setup()

        backgroundColor = .systemFill
    }

    func embed(
		draggableViewViewController: DraggableViewViewController<DraggableContainerView>
	) {
        sv(
            draggableViewViewController.view
        )

        draggableViewViewController.view
            .top(toSafeAreaOf: self)
            .leading(0)
            .trailing(0)
            .bottom(0)

		draggableViewViewController.draggableView.Height == draggableViewViewController.view.Height
    }
}

extension MainRootView: StateDriven {
    public struct State: EmptyInitializable, Equatable {
        public init() {}
    }

    public func render(_ state: State) {}
}
