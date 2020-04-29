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

public class DraggableViewViewController<DraggableView: Draggable>: UIViewController, UIScrollViewDelegate {
    public let draggableView: DraggableView
    public let scrollView = OverlayScrollView()
		|> \.showsVerticalScrollIndicator .~ false
		|> \.showsHorizontalScrollIndicator .~ false
		|> \.bounces .~ false

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
            self.scrollView.contentOffset.y = -self.scrollView.totalDistance(including: self.draggableView.protrusion)
            self.scrollView.contentInset.top = self.scrollView.totalDistance(including: self.draggableView.protrusion)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
    }

    private var scrollDirection: ScrollDirection?
    private var previousYOffset: CGFloat?

    private func animate(_ animations: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 1,
            options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
            animations: animations,
            completion: nil
        )
    }

    public func setExpanded() {
        animate {
            self.scrollView.setContentOffset(
                .init(
                    x: 0,
                    y: -abs(self.scrollView.frame.height - self.draggableView.frame.height)
                ),
                animated: false
            )
        }
    }

    public func setCollapsed() {
        animate {
            self.scrollView.setContentOffset(
                .init(x: 0, y: -self.scrollView.totalDistance(including: self.draggableView.protrusion)),
                animated: false
            )
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defer {
            previousYOffset = self.scrollView.yOffset
        }

        self.scrollView.backgroundColor = UIColor
            .black
            .withAlphaComponent(0.4 * self.scrollView.expandFraction(including: draggableView.protrusion))

        guard let previousY = previousYOffset else { return }

        scrollDirection = self.scrollView.yOffset > previousY ? .down : .up
    }

	private func expandOrCollapse(yOffset: CGFloat) {
        let multiplier: CGFloat = scrollDirection == .up ? 0.8 : 0.2

        if yOffset < multiplier * self.scrollView.totalDistance(including: draggableView.protrusion) {
            setExpanded()
        } else {
            setCollapsed()
        }
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		expandOrCollapse(yOffset: self.scrollView.yOffset)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }

		expandOrCollapse(yOffset: self.scrollView.yOffset)
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
    func totalDistance(including protrusion: CGFloat) -> CGFloat {
		frame.height - safeAreaInsets.bottom - protrusion
    }

    var yOffset: CGFloat {
        abs(contentOffset.y)
    }

    func collapseFraction(including protrusion: CGFloat) -> CGFloat {
        yOffset / totalDistance(including: protrusion)
    }

    func expandFraction(including protrusion: CGFloat) -> CGFloat {
        1 - collapseFraction(including: protrusion)
    }
}
