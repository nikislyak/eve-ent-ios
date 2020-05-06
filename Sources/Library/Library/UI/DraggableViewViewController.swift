//
//  DraggableViewViewController.swift
//  Library
//
//  Created by Nikita Kislyakov on 18.04.2020.
//

import Foundation
import UIKit
import Stevia

public protocol Draggable: UIView {
    var protrusion: CGFloat { get }
}

public protocol DraggableViewViewControllerDelegate: class {
	func didExpand()
	func didCollapse()
}

public class DraggableViewViewController<DraggableView: Draggable>: UIViewController, UIScrollViewDelegate {
    public let draggableView: DraggableView

    public let scrollView = OverlayScrollView()
		|> \.showsVerticalScrollIndicator .~ false
		|> \.showsHorizontalScrollIndicator .~ false
		|> \.bounces .~ false

	public weak var delegate: DraggableViewViewControllerDelegate?

    public init(draggableView: DraggableView) {
        self.draggableView = draggableView

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    public override func loadView() {
        view = OverlayView()

        view.sv(
            scrollView.sv(
                draggableView
            )
        )

        scrollView.fillContainer()

        draggableView.Leading == scrollView.frameLayoutGuide.Leading
        draggableView.Leading == scrollView.contentLayoutGuide.Leading
        draggableView.Trailing == scrollView.frameLayoutGuide.Trailing
        draggableView.Trailing == scrollView.contentLayoutGuide.Trailing
        draggableView.Top == scrollView.contentLayoutGuide.Top
        draggableView.Bottom == scrollView.contentLayoutGuide.Bottom
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.async {
			let offset = self.scrollView.totalDistance(excluding: self.draggableView.protrusion)
			let bottomInset = self.scrollView.safeAreaInsets.bottom

            self.scrollView.contentOffset.y = -offset
            self.scrollView.contentInset.top = offset
			self.scrollView.contentInset.bottom = -bottomInset

			self.delegate?.didCollapse()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
    }

    private var scrollDirection: ScrollDirection?
    private var previousYOffset: CGFloat?

	private func animate(_ animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 1,
            options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
            animations: animations,
			completion: {
				guard $0 else { return }
				completion?()
			}
        )
    }

    public func setExpanded(completion: (() -> Void)? = nil) {
        animate({
            self.scrollView.setContentOffset(
                .init(
                    x: 0,
                    y: -max(self.scrollView.frame.height - self.draggableView.frame.height, 0)
                ),
                animated: false
            )
		}, completion: completion)
    }

    public func setCollapsed(completion: (() -> Void)? = nil) {
        animate({
            self.scrollView.setContentOffset(
                .init(x: 0, y: -self.scrollView.totalDistance(excluding: self.draggableView.protrusion)),
                animated: false
            )
        }, completion: completion)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defer {
            previousYOffset = scrollView.yOffset
        }

        scrollView.backgroundColor = UIColor
            .black
            .withAlphaComponent(0.4 * scrollView.expandFraction(excluding: draggableView.protrusion))

        guard let previousY = previousYOffset else { return }

        scrollDirection = scrollView.yOffset > previousY ? .down : .up
    }

	private func expandOrCollapse(yOffset: CGFloat) {
        let multiplier: CGFloat = scrollDirection == .up ? 0.8 : 0.2

        if yOffset < multiplier * scrollView.totalDistance(excluding: draggableView.protrusion) {
			setExpanded { [weak delegate] in delegate?.didExpand() }
        } else {
			setCollapsed { [weak delegate] in delegate?.didCollapse() }
        }
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		expandOrCollapse(yOffset: scrollView.yOffset)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }

		expandOrCollapse(yOffset: scrollView.yOffset)
    }

	public func scrollViewWillEndDragging(
		_ scrollView: UIScrollView,
		withVelocity velocity: CGPoint,
		targetContentOffset: UnsafeMutablePointer<CGPoint>
	) {
		expandOrCollapse(yOffset: abs(targetContentOffset.pointee.y))
	}
}

private enum ScrollDirection {
    case up
    case down
}

private extension UIScrollView {
	var totalVerticalInsetsHeight: CGFloat {
		safeAreaInsets.top + safeAreaInsets.bottom
	}

	var totalDistance: CGFloat {
		frame.height - totalVerticalInsetsHeight
	}

    func totalDistance(excluding protrusion: CGFloat) -> CGFloat {
		totalDistance - protrusion
    }

    var yOffset: CGFloat {
        abs(contentOffset.y)
    }

    func collapseFraction(excluding protrusion: CGFloat) -> CGFloat {
        yOffset / totalDistance(excluding: protrusion)
    }

    func expandFraction(excluding protrusion: CGFloat) -> CGFloat {
        1 - collapseFraction(excluding: protrusion)
    }
}
