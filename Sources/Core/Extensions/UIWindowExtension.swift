//
//  UIWindowExtension.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/30.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import AuthenticationServices

#if canImport(UIKit)
extension UIWindow: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        self
    }

}
#endif
