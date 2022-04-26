//
//  SolanaTransactionInfo.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/18.
//

import Foundation

public struct SolanaTransactionInfo {

    public let message: String

    public let appendTx: [String: Data]?

    public let publicKeySignaturePairs: [String: String]

}
