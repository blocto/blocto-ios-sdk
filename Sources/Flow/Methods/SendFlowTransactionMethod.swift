//
//  SendFlowTransactionMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/3.
//

import Foundation
import Cadence

public struct SendFlowTransactionMethod: CallbackMethod {
    public typealias Response = String

    public let id: UUID
    public let type: String = FlowMethodType.sendTransaction.rawValue
    public let from: Address
    public let transactionInfo: FlowTransactionInfo
    public let callback: Callback

    let blockchain: Blockchain = .flow

    /// initialize request account method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - from: Pre-defined Cadence Address.
    ///   - transactionInfo: Elements describe Flow transaction.
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        from: Address,
        transactionInfo: FlowTransactionInfo,
        callback: @escaping Callback
    ) {
        self.id = id
        self.from = from
        self.transactionInfo = transactionInfo
        self.callback = callback
    }

    public func encodeToURL(appId: String, baseURLString: String) throws -> URL? {
        guard let baseURL = URL(string: baseURLString),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        var queryItems: [QueryItem] = URLEncoding.queryItems(
            appId: appId,
            requestId: id.uuidString,
            blockchain: blockchain
        )

        queryItems.append(contentsOf: [
            QueryItem(name: .method, value: type),
            QueryItem(name: .from, value: from.hexStringWithPrefix),
            QueryItem(name: .script, value: transactionInfo.script),
            QueryItem(name: .arguments, value: transactionInfo.arguments),
            QueryItem(name: .rawPayload, value: transactionInfo.rawPayload),
            QueryItem(name: .payloadHash, value: transactionInfo.hash),
            QueryItem(name: .gasLimit, value: transactionInfo.gasLimit)
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
