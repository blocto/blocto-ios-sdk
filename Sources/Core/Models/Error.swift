//
//  Error.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

public enum BloctoSDKError: Swift.Error {
    // internal
    case callbackSelfNotfound
    case encodeToURLFailed
    case webSDKSessionFailed
    case decodeFailed
    case responseUnexpected
    case urlNotFound
    case feePayerNotFound

    // info check
    case appIdNotSet

    // query
    case userRejected
    case forbiddenBlockchain
    case invalidResponse
    case userNotMatch

    // format check
    case ethSignInvalidHexString

    // web SDK
    case userCancel
    case redirectURLNotFound
    case sessionError(code: Int)

    case other(code: String)

    init(code: String) {
        switch code {
        case Self.appIdNotSet.rawValue:
            self = .appIdNotSet
        case Self.userRejected.rawValue:
            self = .userRejected
        case Self.forbiddenBlockchain.rawValue:
            self = .forbiddenBlockchain
        case Self.invalidResponse.rawValue:
            self = .invalidResponse
        case Self.userNotMatch.rawValue:
            self = .userNotMatch
        case Self.ethSignInvalidHexString.rawValue:
            self = .ethSignInvalidHexString
        case Self.userCancel.rawValue:
            self = .userCancel
        case Self.redirectURLNotFound.rawValue:
            self = .redirectURLNotFound
        default:
            self = .other(code: code)
        }
    }

    var rawValue: String {
        switch self {
        case .callbackSelfNotfound:
            return ""
        case .encodeToURLFailed:
            return ""
        case .webSDKSessionFailed:
            return ""
        case .decodeFailed:
            return ""
        case .responseUnexpected:
            return ""
        case .urlNotFound:
            return ""
        case .feePayerNotFound:
            return ""
        case .appIdNotSet:
            return "app_id_not_set"
        case .userRejected:
            return "user_rejected"
        case .forbiddenBlockchain:
            return "forbidden_blockchain"
        case .invalidResponse:
            return "invalid_response"
        case .userNotMatch:
            return "user_not_match"
        case .ethSignInvalidHexString:
            return "eth_sign_invalid_hex_string"
        case .userCancel:
            return "webSDK_user_cancel"
        case .redirectURLNotFound:
            return "webSDK_redirect_url_not_found"
        case let .sessionError(code):
            return "webSDK_session_error_\(code)"
        case let .other(code):
            return code
        }
    }

}
