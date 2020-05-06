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

class DraggableViewItemCell: BaseCollectionViewCell {
	private var bag = Set<AnyCancellable>()

	private let stackView = UIStackView()
		|> \.axis .~ .vertical
		|> \.spacing .~ 8

	private let imageView = UIImageView()
		|> \.contentMode .~ .center
		|> \.image .~ UIImage(systemName: "person.fill")
		|> \.clipsToBounds .~ true
		|> \.layer.cornerRadius .~ 25
		|> \.backgroundColor .~ .tertiarySystemBackground
		|> \.tintColor .~ .systemFill

	private let titleLabel = UILabel()
		|> \.textColor .~ .secondaryLabel
		|> \.font .~ .systemFont(ofSize: 14)
		|> \.textAlignment .~ .center

	override func setup() {
		super.setup()

		contentView.backgroundColor = .clear

		contentView.sv(
			stackView.with(
				imageView.size(50),
				titleLabel
			)
		)

		stackView.fillContainer()
	}

	func fill(with model: DraggableViewItemCellModel) {
		titleLabel.text = model.title
	}
}

struct DraggableViewItemCellViewModel: CollectionCellViewModel {
	var id: String {
		model.id
	}

	var accessibilityFormat: CellAccessibilityFormat {
		.init(stringLiteral: "")
	}

	var model: DraggableViewItemCellModel

	func apply(to cell: UICollectionViewCell) {
		guard let cell = cell as? DraggableViewItemCell else { return }

		cell.fill(with: model)
	}

	var registrationInfo: ViewRegistrationInfo {
		.init(classType: DraggableViewItemCell.self)
	}
}

struct DraggableViewItemCellModel: Equatable {
	var id: String
	var title: String
}

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
		|> \.layoutMargins .~ .init(top: 0, left: 0, bottom: 0, right: 0)

	private lazy var layout = UICollectionViewFlowLayout()
		|> \.minimumLineSpacing .~ 16
		|> \.minimumInteritemSpacing .~ 16
		|> \.itemSize .~ UICollectionViewFlowLayout.automaticSize
		|> \.estimatedItemSize .~ UICollectionViewFlowLayout.automaticSize
		|> \.scrollDirection .~ .horizontal

	private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		|> \.backgroundColor .~ .clear
		|> \.contentInset .~ .init(top: 16, left: 8, bottom: 16, right: 8)
		|> \.bounces .~ true
		|> \.alwaysBounceHorizontal .~ true
		|> \.showsVerticalScrollIndicator .~ false
		|> \.showsHorizontalScrollIndicator .~ false

	private lazy var driver = CollectionViewDriver<String>(collectionView: collectionView)

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
				collectionView.height(150),
				UIView()
			)
		)

		rootStackView.fillContainer()

		view.top(8).bottom(8).width(40).height(6).centerHorizontally()
	}

	func set(items: [DraggableViewItemCellModel]) {
		let section = CollectionSectionViewModel(
			id: "",
			cellViewModels: items.map(DraggableViewItemCellViewModel.init)
		)

		driver.update(collectionViewModel: CollectionViewModel(sectionModels: [section]))
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
