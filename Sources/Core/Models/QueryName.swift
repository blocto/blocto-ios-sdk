//
//  QueryName.swift
//  Alamofire
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

enum QueryName: String {
    // request
    case appId = "app_id"
    case requestId = "request_id"
    case blockchain
    case method

    // response
    case address
    case signature
    case txHash = "tx_hash"

    // error
    case error
}
