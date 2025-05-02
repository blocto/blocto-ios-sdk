//
//  ErrorHandler.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/8/18.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import BloctoSDK

protocol ErrorMessaging {
    
    var message: String { get }
    
}

enum ErrorHandler {
    
    static func handleGeneralError(label: UILabel, error: Swift.Error) {
        if let error = error as? BloctoSDKError {
            switch error {
            case .callbackSelfNotfound:
                label.text = "weak self not found."
            case .encodeToURLFailed:
                label.text = "url encode failed."
            case .webSDKSessionFailed:
                label.text = "webSDK session failed."
            case .decodeFailed:
                label.text = "decode failed."
            case .responseUnexpected:
                label.text = "api response unexpected."
            case .urlNotFound:
                label.text = "url not found."
            case .feePayerNotFound:
                label.text = "fee payer not found."
            case .appIdNotSet:
                label.text = "app id not set."
            case .userRejected:
                label.text = "user rejected."
            case .forbiddenBlockchain:
                label.text = "Forbidden blockchain. You should check blockchain selection on Blocto developer dashboard."
            case .invalidResponse:
                label.text = "invalid response."
            case .userNotMatch:
                label.text = "user not matched."
            case .ethSignInvalidHexString:
                label.text = "input text invalid, should be hex string with 0x prefix."
            case .userCancel:
                label.text = "user canceled."
            case .redirectURLNotFound:
                label.text = "redirect url not found."
            case let .sessionError(code):
                label.text = "ASWebAuthenticationSessionError \(code)"
            case let .other(code):
                label.text = code
            case .urlComponentsNotFound:
                label.text = "url components not found."
            case .functionNotImplemented:
                label.text = "web post request not implemented."
            case .sessionIdNotProvided:
                label.text = "make sure to request account first."
            case .postRequestFailed(reason: let reason):
                label.text = "request from web failed with reason: \(reason)"
            }
        } else if let error = error as? ErrorMessaging {
            label.text = error.message
        } else {
            debugPrint(error)
            label.text = error.localizedDescription
        }
        label.textColor = .red
    }
    
}
