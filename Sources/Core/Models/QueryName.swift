//
//  QueryName.swift
//  Alamofire
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

public enum QueryName: String {
    // request
    case appId = "app_id"
    case requestId = "request_id"
    case blockchain
    case method
    case from
    case to
    case value
    case data
    case message
    case signType = "type"
    case isInvokeWrapped = "is_invoke_wrapped"
    case appendTx = "append_tx"
    case publicKeySignaturePairs = "public_key_signature_pairs"

    // flow only
    case flowAppId = "flow_app_id"
    case flowNonce = "flow_nonce"
    case accountProof = "account_proof"
    case userSignature = "user_signature"
    case flowTransaction = "flow_transaction"

    // response
    case address
    case signature
    case txHash = "tx_hash"

    // flow account proof
    case keyId = "key_id"

    // error
    case error

    case platform
}
