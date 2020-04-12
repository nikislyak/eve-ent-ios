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

class OverlayView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
            return nil
        } else {
            return view
        }
    }
}

class OverlayScrollView: UIScrollView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
            return nil
        } else {
            return view
        }
    }
}

public class MainRootView: BaseView {
    func didLayout() {
        dragViewHeightConstraint?.constant = -scrollView.safeAreaInsets.bottom
        scrollView.contentInset = .init(top: self.scrollView.totalDistance, left: 0, bottom: 0, right: 0)
        scrollView.contentOffset = .init(x: 0, y: -self.scrollView.totalDistance)
    }

    private lazy var scrollView = OverlayScrollView()
        |> \.delegate .~ self
        |> \.bounces .~ false
        |> \.showsVerticalScrollIndicator .~ false
        |> \.showsHorizontalScrollIndicator .~ false

    private let rootStackView = UIStackView()
        |> \.axis .~ .vertical

    private let stackView = UIStackView()
        |> \.axis .~ .vertical
        |> \.isLayoutMarginsRelativeArrangement .~ true
        |> \.layoutMargins .~ .init(top: 0, left: 8, bottom: 8, right: 8)

    private let dragContainerView = UIView()
        |> \.backgroundColor .~ .darkGray
        |> \.clipsToBounds .~ true
        |> \.layer.cornerRadius .~ 12
        |> \.layer.maskedCorners .~ [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    private let dragView = UIView()
        |> \.backgroundColor .~ .darkGray
        |> \.clipsToBounds .~ true

    private var dragViewHeightConstraint: NSLayoutConstraint?

    override func setup() {
        super.setup()

        backgroundColor = .systemFill

        let view = UIView()
            .height(8)
            .width(40)
            |> \.backgroundColor .~ .lightGray
            |> \.layer.cornerRadius .~ 4
            |> \.clipsToBounds .~ true

        sv(
            scrollView.sv(
                dragContainerView.sv(
                    rootStackView.with(
                        dragView.sv(view),
                        stackView.with(
                            UIView() |> \.backgroundColor .~ .clear
                        )
                    )
                )
            )
        )

        scrollView
            .top(toSafeAreaOf: self)
            .left(toSafeAreaOf: self)
            .right(toSafeAreaOf: self)
            .bottom(0)

        rootStackView.fillContainer()

        dragViewHeightConstraint = dragContainerView.heightAnchor.constraint(
            equalTo: scrollView.frameLayoutGuide.heightAnchor
        )

        dragViewHeightConstraint?.isActive = true

        dragContainerView.Leading == scrollView.frameLayoutGuide.Leading
        dragContainerView.Trailing == scrollView.frameLayoutGuide.Trailing
        dragContainerView.Leading == scrollView.contentLayoutGuide.Leading
        dragContainerView.Trailing == scrollView.contentLayoutGuide.Trailing
        dragContainerView.Top == scrollView.contentLayoutGuide.Top
        dragContainerView.Bottom == scrollView.contentLayoutGuide.Bottom

        view.top(4).bottom(4).centerHorizontally()
    }
}

private enum ScrollDirection {
    case up
    case down
}

private var scrollDirection: ScrollDirection?
private var previousYOffset: CGFloat?

extension MainRootView: UIScrollViewDelegate {
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

    private func setExpanded() {
        animate {
            self.scrollView.setContentOffset(.zero, animated: false)
        }
    }

    private func setCollapsed() {
        animate {
            self.scrollView.setContentOffset(.init(x: 0, y: -self.scrollView.totalDistance), animated: false)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defer {
            previousYOffset = self.scrollView.yOffset
        }

        self.scrollView.backgroundColor = UIColor.black.withAlphaComponent(0.4 * self.scrollView.expandFraction)

        guard let previousY = previousYOffset else { return }

        scrollDirection = self.scrollView.yOffset > previousY ? .down : .up
    }

    private func expandOrCollapse() {
        let multiplier: CGFloat = scrollDirection == .up ? 0.9 : 0.1

        if self.scrollView.yOffset < multiplier * self.scrollView.totalDistance {
            setExpanded()
        } else {
            setCollapsed()
        }
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        expandOrCollapse()
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }

        expandOrCollapse()
    }
}

extension MainRootView: StateDriven {
    public struct State: EmptyInitializable, Equatable {
        public init() {}
    }
    
    public func render(_ state: State) {}
}

private extension UIScrollView {
    var totalDistance: CGFloat {
        frame.height - safeAreaInsets.bottom - 16
    }

    var yOffset: CGFloat {
        abs(contentOffset.y)
    }

    var collapseFraction: CGFloat {
        yOffset / totalDistance
    }

    var expandFraction: CGFloat {
        1 - collapseFraction
    }
}
