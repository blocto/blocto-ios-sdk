//
//  CallbackMethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/11.
//

import Foundation

public enum CallbackMethodContentType {

    case requestAccount(
        requestId: String,
        address: String)

    case signMessage(
        requestId: String,
        signature: String)

    case signAndSendTransaction(
        requestId: String,
        txHash: String)
    
    case error(
        requestId: String,
        error: QueryError)

}
