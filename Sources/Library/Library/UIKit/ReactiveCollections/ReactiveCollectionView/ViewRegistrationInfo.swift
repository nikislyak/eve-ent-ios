//
//  ViewRegistrationInfo.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation
import UIKit

public protocol ReusableCellProtocol {
    var registrationInfo: ViewRegistrationInfo { get }
}

public struct ViewRegistrationInfo: Equatable {
    public let reuseIdentifier: String
    
    public let registrationMethod: ViewRegistrationMethod
    
    public init(classType: AnyClass) {
        self.reuseIdentifier = "\(classType)"
        self.registrationMethod = .fromClass(classType)
    }
    
    public init(classType: AnyClass, nibName: String, bundle: Bundle? = nil) {
        self.reuseIdentifier = "\(classType)"
        self.registrationMethod = .fromNib(name: nibName, bundle: bundle)
    }
}

public enum ViewRegistrationMethod {
    case fromClass(AnyClass)
    case fromNib(name: String, bundle: Bundle?)
    
    var nib: UINib? {
        switch self {
        case let .fromNib(name, bundle):
            return UINib(nibName: name, bundle: bundle)
        case .fromClass:
            return nil
        }
    }
}

extension ViewRegistrationMethod: Equatable {
    public static func == (lhs: ViewRegistrationMethod, rhs: ViewRegistrationMethod) -> Bool {
        switch (lhs, rhs) {
        case let (.fromClass(lhsClass), .fromClass(rhsClass)):
            return lhsClass == rhsClass
        case let (.fromNib(lhsName, lhsBundle), .fromNib(rhsName, rhsBundle)):
            return lhsName == rhsName && lhsBundle == rhsBundle
        default:
            return false
        }
    }
}
