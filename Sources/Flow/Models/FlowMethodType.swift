//
//  FlowMethodType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation

public enum FlowMethodType: String {
    case requestAccount = "request_account"
    case authenticate = "authn"
    case userSignature = "user_signature"
    case sendTransaction = "flow_send_transaction"
}
