//
//  EVMBaseTransaction.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import BigInt

public struct EVMBaseTransaction {
    public let from: String
    public let to: String
    public let value: BigUInt
    public let data: Data
    public let gas: BigUInt? // The amount of gas to use for the transaction
    public let maxPriorityFeePerGas: BigUInt? // The maximum fee per gas to give miners to incentivize them to include the transaction
    public let maxFeePerGas: BigUInt? // The maximum fee per gas that the transaction is willing to pay in total

    public init(
        from: String,
        to: String,
        value: BigUInt = 0,
        data: Data = Data(),
        gas: BigUInt? = nil,
        maxPriorityFeePerGas: BigUInt? = nil,
        maxFeePerGas: BigUInt? = nil
    ) {
        self.to = to
        self.from = from
        self.value = value
        self.data = data
        self.gas = gas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.maxFeePerGas = maxFeePerGas
    }

}
