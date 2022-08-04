//
//  CallbackMethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/11.
//

import Foundation

public enum CallbackMethodContentType {

    case requestAccount(address: String)

    case signMessage(signature: String)

    case signAndSendTransaction(txHash: String)
    
    // flow
    case authanticate(address: String, accountProof: [FlowCompositeSignature])
    
    case flowSignMessage(signatures: [FlowCompositeSignature])

    case error(error: BloctoSDKError)

}
