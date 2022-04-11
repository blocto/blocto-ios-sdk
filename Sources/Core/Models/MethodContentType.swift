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
        message: String,
        extraPublicKeySignaturePairs: [String: String])
}
