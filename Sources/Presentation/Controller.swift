//
//  Controller.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.01.2020.
//

import Foundation
import UIKit
import Combine

protocol StateDriven: class {
    associatedtype State
    
    func render(_ state: State)
}

class BaseController<View: UIView & StateDriven>: UIViewController, UserInterfaceModule where View.State: EmptyInitializable {
    let useCasesFactory: UseCasesFactory
    let router: RouterAbstraction
    
    var state: View.State = .init() {
        didSet {
            guard typedView != nil else {
                return
            }
            
            typedView.render(state)
        }
    }
    
    var bag = Set<AnyCancellable>()
    
    required init(useCasesFactory: UseCasesFactory, router: RouterAbstraction) {
        self.useCasesFactory = useCasesFactory
        self.router = router
        
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    /// Override point
    func setup() {}
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var typedView: View!
    
    override func loadView() {
        typedView = View()
        view = typedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeSubscriptions().store(in: &bag)
    }
    
    /// Override point
    func makeSubscriptions() -> [AnyCancellable] {
        []
    }
    
    /// Override point
    class var keyboardManagerClass: KeyboardManager.Type {
        ScrollViewInsetAdjustingKeyboardManager.self
    }
    
    private(set) lazy var keyboardManager = type(of: self).keyboardManagerClass.init()
}
