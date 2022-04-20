//
//  SolanaTransactionInfo.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/18.
//

import Foundation

public struct SolanaTransactionInfo {

    let message: String

    let appendTx: [String: Data]?

    let publicKeySignaturePairs: [String: String]

}
