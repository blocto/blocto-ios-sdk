//
//  FlowMethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation

public enum FlowMethodContentType {
    
    case authenticate(accountProofData: AccountProofData?)
    
    case userSignature(from: String, message: String)
    
    // TODO: implementation
//    case signMessage(
//        from: String,
//        message: String,
//        signType: EVMBaseSignType)
//
//    case sendTransaction(
//        transaction: EVMBaseTransaction)
    
}
