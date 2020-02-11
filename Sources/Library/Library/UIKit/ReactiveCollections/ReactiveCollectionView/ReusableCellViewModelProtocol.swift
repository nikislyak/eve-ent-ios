//
//  ReusableCellViewModelProtocol.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation

public protocol ReusableCellViewModelProtocol {
    var registrationInfo: ViewRegistrationInfo { get }
}

public protocol ReusableSupplementaryViewModelProtocol {
    var viewInfo: SupplementaryViewInfo? { get }
}
