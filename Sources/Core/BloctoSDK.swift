//
//  BloctoSDK.swift
//  BloctoSDK
//
//  Created by Scott on 2022/1/12.
//

import Foundation

final public class BloctoSDK {

    /// For now, it's optional.
    private let appId: String?
    private let appName: String
    private let appImageURLString: String?

    init(appId: String?, appName: String, appImageURLString: String?) {
        self.appId = appId
        self.appName = appName
        self.appImageURLString = appImageURLString
    }

    func requestAccount(blockchain: Blockchain, completion: (Result<String, BlockSDKError>) -> Void) {
        // address
    }

    func signMessage(blockchain: Blockchain, message: String, completion: (Result<String, BlockSDKError>) -> Void) {
        // signature
    }

}
