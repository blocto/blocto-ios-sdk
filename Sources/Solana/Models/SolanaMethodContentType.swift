//
//  SolanaMethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/16.
//

import Foundation

public enum SolanaMethodContentType {

    case requestAccount

    case signAndSendTransaction(
        from: String,
        isInvokeWrapped: Bool,
        transactionInfo: SolanaTransactionInfo)

}
