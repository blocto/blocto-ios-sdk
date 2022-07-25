//
//  CompositeSignature.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation

public struct CompositeSignature: Decodable {

    public let address: String
    public let keyId: Int
    /// hex string
    public let signature: String

    public init(
        address: String,
        keyId: Int,
        signature: String
    ) {
        self.address = address
        self.keyId = keyId
        self.signature = signature
    }
}

extension CompositeSignature {

    init?(param: [String: String]) {
        guard let address = param["address"] else {
            return nil
        }
        guard let keyIdString = param["keyId"],
              let keyId = Int(keyIdString) else {
            return nil
        }
        guard let signature = param["signature"] else {
            return nil
        }
        self.address = address
        self.keyId = keyId
        self.signature = signature
    }

}
