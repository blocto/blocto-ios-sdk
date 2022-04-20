//
//  ConvertTransactionRequest.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/18.
//

import Moya

public struct ConvertTransactionRequest: TargetType {

    let solanaAddress: String
    let message: String

    public var baseURL: URL { AppConstants.apiBaseURL }

    public var path: String { "/solana/createRawTransaction" }

    public var method: Moya.Method { .post }

    public var task: Task {
        .requestParameters(
            parameters: [
                "sol_address": solanaAddress,
                "raw_tx": message
            ],
            encoding: JSONEncoding.default)
    }

    public var headers: [String: String]? {
        [
            "blocto-sdk-platform": "iOS",
            "blocto-sdk-version": AppInfo.appVersion
        ]
    }

}
