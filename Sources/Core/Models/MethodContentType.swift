//
//  MethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/31.
//

import Foundation

public enum MethodContentType {
    case requestAccount

    case signMessage(
        from: String,
        message: String)

    case signAndSendTransaction(
        from: String,
        isInvokeWrapped: Bool,
        transactionInfo: SolanaTransactionInfo)

    var rawValue: String {
        switch self {
            case .requestAccount:
                return MethodType.requestAccount.rawValue
            case .signMessage:
                return MethodType.signMessage.rawValue
            case .signAndSendTransaction:
                return MethodType.signAndSendTransaction.rawValue
        }
    }
}
