//
//  SignAndSendSolanaTransactionMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/8.
//

import SolanaWeb3

public struct SignAndSendSolanaTransactionMethod: CallbackMethod {
    public typealias Response = String

    public let id: UUID
    public let type: MethodType = .signAndSendTransaction
    public let from: String
    public let transactionInfo: SolanaTransactionInfo
    public let isInvokeWrapped: Bool
    public let callback: Callback

    let blockchain: Blockchain

    /// initialize request account method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - blockchain: pre-defined blockchain in BloctoSDK
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        blockchain: Blockchain,
        from: String,
        transactionInfo: SolanaTransactionInfo,
        isInvokeWrapped: Bool = true,
        callback: @escaping Callback
    ) {
        self.id = id
        self.blockchain = blockchain
        self.from = from
        self.transactionInfo = transactionInfo
        self.isInvokeWrapped = isInvokeWrapped
        self.callback = callback
    }

    public func encodeToURL(appId: String, baseURLString: String) throws -> URL? {
        guard let baseURL = URL(string: baseURLString),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
                  return nil
              }
        let queryItems = URLEncoding.queryItems(
            appId: appId,
            requestId: id.uuidString,
            blockchain: blockchain,
            method: .signAndSendTransaction(
                from: from,
                isInvokeWrapped: true,
                transactionInfo: SolanaTransactionInfo(
                    message: transactionInfo.message,
                    appendTx: transactionInfo.appendTx,
                    publicKeySignaturePairs: transactionInfo.publicKeySignaturePairs)))
        components.queryItems = URLEncoding.encode(queryItems)
        return components.url
    }

    public func resolve(components: URLComponents, logging: Bool) {
        if let errorCode = components.queryItem(for: .error) {
            callback(.failure(QueryError(code: errorCode)))
            return
        }
        let targetQueryName = QueryName.txHash
        guard let txHash = components.queryItem(for: targetQueryName) else {
            log(
                enable: logging,
                message: "\(targetQueryName.rawValue) not found.")
            callback(.failure(QueryError.invalidResponse))
            return
        }
        callback(.success(txHash))
    }

    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}
