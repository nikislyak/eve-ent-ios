//
//  GatewaysFactory.swift
//  Domain
//
//  Created by Nikita Kislyakov on 21.01.2020.
//

import Foundation

public protocol GatewaysFactory {
    func makeAuthorizationGateway() -> AuthorizationGateway
    func makeTokensStorageGateway() -> TokensStorageGateway
}
