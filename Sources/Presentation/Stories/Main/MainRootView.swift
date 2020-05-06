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
	private var draggableViewController: DraggableViewViewController<DraggableContainerView>!

    override func setup() {
        super.setup()

        backgroundColor = .systemFill
    }

    func embed(
		draggableViewViewController: DraggableViewViewController<DraggableContainerView>
	) {
		draggableViewController = draggableViewViewController

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
		var items = DraggableViewItemCellModel.stubbed

        public init() {}
    }

    public func render(_ state: State) {
		draggableViewController.draggableView.set(items: state.items)
	}
}

extension DraggableViewItemCellModel {
	static let stubbed: [DraggableViewItemCellModel] = (0 ..< .random(in: 1 ... 100)).map {
		.init(id: .init($0), title: .init($0))
	}
}
