//
//  MainController.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation
import UIKit
import Combine
import Library

class DraggableContainerView: BaseView, Draggable {
    var protrusion: CGFloat {
        dragView.frame.height
    }

    private let dragView = UIView()
        |> \.backgroundColor .~ .systemGray4
        |> \.clipsToBounds .~ true

    private let rootStackView = UIStackView()
        |> \.axis .~ .vertical
        |> \.isLayoutMarginsRelativeArrangement .~ true
        |> \.layoutMargins .~ .init(top: 0, left: 8, bottom: 0, right: 8)

    override func setup() {
        super.setup()

        backgroundColor = .systemGray4

        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16
        clipsToBounds = true

        let view = UIView()
			|> \.backgroundColor .~ .systemGray2
			|> \.layer.cornerRadius .~ 4
			|> \.clipsToBounds .~ true

        sv(
            rootStackView.with(
                dragView.sv(view),
                UIView()
            )
        )

        rootStackView.fillContainer()

        view.top(8).bottom(8).width(40).height(4).centerHorizontally()
    }
}

public class MainController: BaseController<MainRootView> {
    private var draggableViewController: DraggableViewViewController<DraggableContainerView>!

    public override func loadView() {
        super.loadView()

		let draggableContainerView = DraggableContainerView()
        let draggableViewController = DraggableViewViewController(draggableView: draggableContainerView)

        addChild(draggableViewController)

		typedView.embed(
			draggableViewViewController: draggableViewController
		)

        draggableViewController.didMove(toParent: self)

        self.draggableViewController = draggableViewController
    }

    override func setup() {
        super.setup()
        
        navigationItem.title = "Main"
        tabBarItem.title = "Main"
        tabBarItem.image = UIImage(systemName: "circle.grid.3x3.fill")
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(close))
    }

    @objc func close() {
		context.router.navigateToAuth()
    }
}
