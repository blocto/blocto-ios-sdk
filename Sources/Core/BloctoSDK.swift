//
//  BloctoSDK.swift
//  BloctoSDK
//
//  Created by Scott on 2022/1/12.
//

import Foundation

final public class BloctoSDK {

    private let appId: String?

    init(appId: String) {
        self.appId = appId
    }

    func requestAccount(blockchain: Blockchain, completion: (Result<String, BlockSDKError>) -> Void) {
        // address
    }

    func signMessage(blockchain: Blockchain, message: String, completion: (Result<String, BlockSDKError>) -> Void) {
        // signature
    }

}
