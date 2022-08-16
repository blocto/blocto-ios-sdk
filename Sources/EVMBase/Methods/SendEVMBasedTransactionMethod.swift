//
//  SendEVMBasedTransactionMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/12.
//

import Foundation
import BigInt

public struct SendEVMBasedTransactionMethod: CallbackMethod {
    public typealias Response = String

    public let id: UUID
    public let type: String = EVMBaseMethodType.sendTransaction.rawValue
    public let callback: Callback

    let blockchain: Blockchain
    let transaction: EVMBaseTransaction

    /// initialize request account method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - blockchain: pre-defined blockchain in BloctoSDK
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        blockchain: Blockchain,
        transaction: EVMBaseTransaction,
        callback: @escaping Callback
    ) {
        self.id = id
        self.blockchain = blockchain
        self.transaction = transaction
        self.callback = callback
    }

    public func encodeToURL(appId: String, baseURLString: String) throws -> URL? {
        guard let baseURL = URL(string: baseURLString),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        var queryItems = URLEncoding.queryItems(
            appId: appId,
            requestId: id.uuidString,
            blockchain: blockchain
        )
        queryItems.append(contentsOf: [
            QueryItem(name: .method, value: type),
            QueryItem(name: .from, value: transaction.from),
            QueryItem(name: .to, value: transaction.to),
            QueryItem(name: .value, value: String(transaction.value, radix: 16).bloctoSDK.add0x),
            QueryItem(name: .data, value: transaction.data),
        ])
        components.queryItems = URLEncoding.encode(queryItems)
        return components.url
    }

    public func resolve(components: URLComponents, logging: Bool) {
        if let errorCode = components.queryItem(for: .error) {
            callback(.failure(BloctoSDKError(code: errorCode)))
            return
        }
        let targetQueryName = QueryName.txHash
        guard let txHash = components.queryItem(for: targetQueryName) else {
            log(
                enable: logging,
                message: "\(targetQueryName.rawValue) not found."
            )
            callback(.failure(BloctoSDKError.invalidResponse))
            return
        }
        callback(.success(txHash))
    }

    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}
