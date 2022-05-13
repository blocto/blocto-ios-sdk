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
    public let to: String
    public let from: String
    public let value: BigUInt
    public let data: Data

    public init(
        to: String,
        from: String,
        value: BigUInt = 0,
        data: Data = Data()
    ) {
        self.to = to
        self.from = from
        self.value = value
        self.data = data
    }

}
