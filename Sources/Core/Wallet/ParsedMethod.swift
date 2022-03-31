//
//  ParsedMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/29.
//

import Foundation

public struct ParsedMethod {

    public let appId: String
    public let requestId: String
    public let blockchain: Blockchain
    public let method: MethodContentType
    
    public init?(param: [String: String]) {
        guard let appId = param[QueryName.appId.rawValue] else { return nil }
        self.appId = appId
        
        guard let requestId = param[QueryName.requestId.rawValue] else { return nil }
        self.requestId = requestId
        
        guard let rawBlockchain = param[QueryName.blockchain.rawValue],
              let blockchain = Blockchain(rawValue: rawBlockchain) else { return nil }
        self.blockchain = blockchain
        
        guard let rawMethod = param[QueryName.method.rawValue],
              let method = MethodType(rawValue: rawMethod) else { return nil }
        switch method {
            case .requestAccount:
                self.method = .requestAccount
            case .signMessage:
                guard let from = param[QueryName.from.rawValue],
                      let message = param[QueryName.message.rawValue] else { return nil }
                self.method = .signMessage(from: from, message: message)
            case .sendTransaction:
                guard let from = param[QueryName.from.rawValue],
                      let message = param[QueryName.message.rawValue] else { return nil }
                self.method = .sendTransaction(from: from, message: message)
        }
    }

}

#if DEBUG
extension ParsedMethod {

    public init(
        appId: String,
        requestId: String,
        blockchain: Blockchain,
        method: MethodContentType
    ) {
        self.appId = appId
        self.requestId = requestId
        self.blockchain = blockchain
        self.method = method
    }

}
#endif
