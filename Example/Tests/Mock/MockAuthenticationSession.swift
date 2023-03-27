//
//  MockAuthenticationSession.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/3/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import BloctoSDK
import AuthenticationServices

class MockAuthenticationSession: AuthenticationSessioning {

    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? {
        get {
            return nil
        }
        set {
            print(newValue.debugDescription)
        }
    }
    var prefersEphemeralWebBrowserSession: Bool = true
    private let completionHandler: (URL?, Error?) -> Void
    private var callbackURLScheme: String?
    private static var callbackURL: URL?

    required init(url URL: URL, callbackURLScheme: String?, completionHandler: @escaping (URL?, Error?) -> Void) {
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completionHandler
    }

    static func setCallbackURL(_ url: URL?) {
        callbackURL = url
    }

    func start() -> Bool {
        if let callbackURL = Self.callbackURL,
           callbackURL.scheme == callbackURLScheme {
            completionHandler(callbackURL, nil)
            return true
        } else {
            completionHandler(Self.callbackURL, InternalError.webSDKSessionFailed)
            return false
        }
    }

    enum InternalError: Swift.Error {
        case webSDKSessionFailed
    }

}
