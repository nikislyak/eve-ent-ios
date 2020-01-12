//
//  Controller.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.01.2020.
//

import Foundation
import UIKit

protocol View: class {
    associatedtype ViewModel
    
    func render(_ viewModel: ViewModel)
}

protocol Presenter: class {
    associatedtype V: View
    associatedtype State: Equatable
    
    var view: V! { get set }
    
    func viewModel(for state: State) -> V.ViewModel
}

class BasePresenter<V: View, State: Equatable & EmptyInitializable>: Presenter {
    let useCasesFactory: UseCasesFactory
    let router: RouterAbstraction
    
    weak var view: V! {
        didSet {
            guard view != nil else {
                return
            }
            
            state = initialState
        }
    }
    
    var state: State {
        didSet {
            guard view != nil else {
                return
            }

            view.render(viewModel(for: state))
        }
    }
    
    private let initialState: State
    
    init(
        initialState: State = .init(),
        useCasesFactory: UseCasesFactory,
        router: RouterAbstraction
    ) {
        self.initialState = initialState
        self.state = initialState
        self.useCasesFactory = useCasesFactory
        self.router = router
    }
    
    func viewModel(for state: State) -> V.ViewModel {
        fatalError()
    }
}

class Controller<V: UIView, P: Presenter>: UIViewController where P.V == V {
    let presenter: P
    
    init(presenter: P) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
