//
//  MethodType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/16.
//

import Foundation

public enum EVMBaseMethodType: String {
    case requestAccount = "request_account"
    case signMessage = "sign_message"
    case sendTransaction = "send_transaction"
}
