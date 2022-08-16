//
//  AuthenticationSessioning.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/25.
//

import Foundation
import AuthenticationServices

public protocol AuthenticationSessioning {

    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }

    init(
        url URL: URL,
        callbackURLScheme: String?,
        completionHandler: @escaping (URL?, Swift.Error?) -> Void
    )

    func start() -> Bool

}

// MARK: - ASWebAuthenticationSession + AuthenticationSessioning

extension ASWebAuthenticationSession: AuthenticationSessioning {}
