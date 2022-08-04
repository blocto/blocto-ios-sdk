//
//  FlowMethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation

public enum FlowMethodContentType {

    case authenticate(accountProofData: FlowAccountProofData?)

    case userSignature(from: String, message: String)

    case sendTransaction(transactionInfo: FlowTransactionInfo)

}
