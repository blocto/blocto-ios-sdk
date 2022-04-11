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
            case QueryError.userRejected.rawValue:
                self = .userRejected
            case QueryError.forbiddenBlockchain.rawValue:
                self = .forbiddenBlockchain
            case QueryError.invalidResponse.rawValue:
                self = .invalidResponse
            default:
                self = .other(code: code)
        }
    }
    
    var rawValue: String {
        switch self {
            case .userRejected:
                return "user_rejected"
            case .forbiddenBlockchain:
                return "forbidden_blockchain"
            case .invalidResponse:
                return "invalid_response"
            case .other(let code):
                return code
        }
    }
    
}
