//
//  FlowAccountProofData.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation

public struct FlowAccountProofData {

    /// A human-readable string e.g. "Blocto", "NBA Top Shot"
    public let appId: String
    /// minimum 32-byte random nonce
    public let nonce: String

    public init(
        appId: String,
        nonce: String
    ) {
        self.appId = appId
        self.nonce = nonce
    }

}
