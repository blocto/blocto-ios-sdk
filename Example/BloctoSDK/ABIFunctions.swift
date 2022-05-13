//
//  ABIFunctions.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/13.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import web3
import BigInt

struct SetValueABIFunction {
    static let name = "setValue"
    let value: BigUInt

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(value)
    }

    func functionData() throws -> Data {
        let encoder = ABIFunctionEncoder(Self.name)
        try encode(to: encoder)
        let data = try encoder.encoded()
        return data
    }
}

struct GetValueABIFunction: ABIFunction {
    static let name = "value"

    var contract: EthereumAddress
    var from: EthereumAddress?

    var gasPrice: BigUInt?
    var gasLimit: BigUInt?

    struct Response: ABIResponse {
        public static var types: [ABIType.Type] = [BigUInt.self]
        public let value: BigUInt

        public init?(values: [ABIDecoder.DecodedValue]) throws {
            self.value = try values[0].decoded()
        }
    }

    func encode(to encoder: ABIFunctionEncoder) throws {}
}

struct DonateABIFunction {
    static let name = "donate"
    let message: String

    func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(message)
    }

    func functionData() throws -> Data {
        let encoder = ABIFunctionEncoder(Self.name)
        try encode(to: encoder)
        let data = try encoder.encoded()
        return data
    }
}
