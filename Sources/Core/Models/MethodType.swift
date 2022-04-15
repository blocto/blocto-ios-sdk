//
//  MethodType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

public enum MethodType: String {
    case requestAccount = "request_account"
    case signMessage = "sign_message"
    case signAndSendTransaction = "sign_and_send_transaction"
}
