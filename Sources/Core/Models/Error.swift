//
//  Error.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

enum InternalError: Swift.Error {
    case appIdNotSet
    case encodeToURLFailed
    case webSDKSessionFailed
}

public enum QueryError: Swift.Error {
    case userRejected
    case forbiddenBlockchain
    case invalidResponse
    case other(code: String)

    init(code: String) {
        switch code {
        case "user_rejected":
            self = .userRejected
        case "forbidden_blockchain":
            self = .forbiddenBlockchain
        case "invalid_response":
            self = .invalidResponse
        default:
            self = .other(code: code)
        }
    }
}
