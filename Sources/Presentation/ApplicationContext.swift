//
//  ApplicationContext.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 12.04.2020.
//

import Foundation
import UIKit
import Domain
import Combine
import Library

public final class ApplicationContext {
    private var bag = Set<AnyCancellable>()

    public let useCasesFactory: UseCasesFactory
    public let validatorsFactory: ValidatorsFactory
	public let router: ApplicationRouter

    public init(
        useCasesFactory: UseCasesFactory,
        validatorsFactory: ValidatorsFactory,
        router: ApplicationRouter
    ) {
        self.useCasesFactory = useCasesFactory
        self.validatorsFactory = validatorsFactory
        self.router = router
    }
}
