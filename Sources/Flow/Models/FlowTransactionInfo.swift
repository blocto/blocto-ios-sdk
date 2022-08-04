//
//  FlowTransactionInfo.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/2.
//

import Foundation

public struct FlowTransactionInfo {

    public let script: String
    public let arguments: [String]
    public let rawPayload: String
    public let hash: String
    public let address: String
    public let gasLimit: UInt64

    public init(
        script: String,
        arguments: [String],
        rawPayload: String,
        hash: String,
        address: String,
        gasLimit: UInt64
    ) {
        self.script = script
        self.arguments = arguments
        self.rawPayload = rawPayload
        self.hash = hash
        self.address = address
        self.gasLimit = gasLimit
    }
}
