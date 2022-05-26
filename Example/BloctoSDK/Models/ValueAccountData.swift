//
//  ValueAccountData.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SolanaWeb3

struct ValueAccountData: BufferLayout {
    let instruction: UInt8
    let value: UInt32
}
