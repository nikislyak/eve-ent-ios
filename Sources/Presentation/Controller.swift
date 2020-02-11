//
//  Controller.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.01.2020.
//

import Foundation
import UIKit
import Combine
import Library
import Domain

public protocol StateDriven: class {
    associatedtype State
    
    func render(_ state: State)
}

public class BaseController<View: UIView & StateDriven>: UIViewController, UserInterfaceModule where View.State: EmptyInitializable {
    let useCasesFactory: UseCasesFactory
    let router: RouterAbstraction
    let validatorsFactory: ValidatorsFactory
    
    var state: View.State = .init() {
        didSet {
            guard typedView != nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.typedView.render(self.state)
            }
        }
    }
    
    var bag = Set<AnyCancellable>()
    
    public required init(
        useCasesFactory: UseCasesFactory,
        validatorsFactory: ValidatorsFactory,
        router: RouterAbstraction
    ) {
        self.useCasesFactory = useCasesFactory
        self.validatorsFactory = validatorsFactory
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
    
    override public func loadView() {
        typedView = View()
        view = typedView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        typedView.render(state)
        
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
