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

public class BaseController<View: UIView & StateDriven>: UIViewController, UserInterfaceModule
where View.State: EmptyInitializable, View.State: Equatable {
    let context: ApplicationContext
    
    @Published var state = View.State()
    
    var bag = Set<AnyCancellable>()
    
    public required init(context: ApplicationContext) {
        self.context = context

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

//        $state
        _state
            .projectedValue
            .removeDuplicates()
            .sink(receiveValue: typedView.render)
            .store(in: &bag)
        
        makeSubscriptions().store(in: &bag)
    }
    
    /// Override point
    func makeSubscriptions() -> [AnyCancellable] {
        []
    }
    
    func async(_ subscribe: () -> Cancellable) {
        subscribe().store(in: &bag)
    }
}
