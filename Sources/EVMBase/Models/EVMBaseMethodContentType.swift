//
//  EVMBaseMethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/16.
//

import Foundation

public enum EVMBaseMethodContentType {

    case requestAccount

    case signMessage(
        from: String,
        message: String,
        signType: EVMBaseSignType
    )

    case sendTransaction(
        transaction: EVMBaseTransaction)

}
