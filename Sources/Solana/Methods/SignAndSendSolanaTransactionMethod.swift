//
//  SignAndSendSolanaTransactionMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/8.
//

import Foundation

public struct SignAndSendSolanaTransactionMethod: CallbackMethod {
    public typealias Response = String

    public let id: UUID
    public let sessionId: String?
    public let type: String = SolanaMethodType.signAndSendTransaction.rawValue
    public let from: String
    public let transactionInfo: SolanaTransactionInfo
    public let isInvokeWrapped: Bool
    public let session: URLSessionProtocol
    public let callback: Callback

    let blockchain: Blockchain

    /// initialize request account method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - sessionId: The session id for web browsing, so if request the account is from native Blocto App then this should be nil.
    ///   - blockchain: pre-defined blockchain in BloctoSDK
    ///   - from: The sender address.
    ///   - transactionInfo: The transaction info.
    ///   - isInvokeWrapped: The indicate whether the transaction already convert to what Blocto contract wallet can execute.
    ///   - session: The session dependency injection for testing.
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        sessionId: String?,
        blockchain: Blockchain,
        from: String,
        transactionInfo: SolanaTransactionInfo,
        isInvokeWrapped: Bool = true,
        session: URLSessionProtocol = URLSession.shared,
        callback: @escaping Callback
    ) {
        self.id = id
        self.sessionId = sessionId
        self.blockchain = blockchain
        self.from = from
        self.transactionInfo = transactionInfo
        self.isInvokeWrapped = isInvokeWrapped
        self.session = session
        self.callback = callback
    }

    public func encodeToNativeURL(appId: String, baseURLString: String) throws -> URL? {
        guard let baseURL = URL(string: baseURLString),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        var queryItems: [QueryItem] = URLEncoding.queryGeneralItems(
            appId: appId,
            requestId: id.uuidString,
            blockchain: blockchain
        )
        queryItems.append(contentsOf: [
            QueryItem(name: .method, value: type),
            QueryItem(name: .from, value: from),
            QueryItem(name: .isInvokeWrapped, value: isInvokeWrapped),
            QueryItem(name: .message, value: transactionInfo.message),
            QueryItem(name: .publicKeySignaturePairs, value: transactionInfo.publicKeySignaturePairs),
        ])
        
        let appendMessageQuryItems: [URLQueryItem] = URLEncoding.solanaAppendMessagesQueryItems(dictionary: transactionInfo.appendTx ?? [:])
        var urlQueryItems: [URLQueryItem] = []
        urlQueryItems.append(contentsOf: appendMessageQuryItems)
        urlQueryItems.append(contentsOf: URLEncoding.encode(queryItems))
        components.queryItems = urlQueryItems
        return components.url
    }

    public func converToWebURLRequest(
        appId: String,
        baseURLString: String
    ) async throws -> URL {
        guard let sessionId else {
            throw BloctoSDKError.sessionIdNotProvided
        }
        let reqeustBody = RequestBody(
            from: from,
            message: transactionInfo.message,
            isInvokeWrapped: isInvokeWrapped,
            publicKeySignaturePairs: transactionInfo.publicKeySignaturePairs,
            appendTx: transactionInfo.appendTx?.reduce(into: [:]) { $0[$1.key] = $1.value.bloctoSDK.hexString } ?? [:]
        )
        let request = try RequestBuilder.buildRequest(
            method: .post,
            methodId: id.uuidString,
            sessionId: sessionId,
            baseURLString: baseURLString,
            path: "api/\(blockchain.rawValue)/dapp/authz",
            body: reqeustBody
        )
        let response: PostRequestResponse = try await session.asyncDataTask(with: request)
        switch response.status {
        case let .pending(authorizationId):
            guard let baseURL = URL(string: baseURLString) else {
                throw BloctoSDKError.urlNotFound
            }
            let newURL = baseURL
                .appendingPathComponent(appId)
                .appendingPathComponent(blockchain.rawValue)
                .appendingPathComponent("authz")
                .appendingPathComponent(authorizationId)
            guard let components = URLComponents(url: newURL, resolvingAgainstBaseURL: true),
                  let url = components.url else {
                throw BloctoSDKError.urlNotFound
            }
            return url
        case let .declined(reason):
            throw BloctoSDKError.postRequestFailed(reason: reason)
        }
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

extension SignAndSendSolanaTransactionMethod {

    struct RequestBody: Encodable {
        let from: String // The address for the sending account
        let message: String // Transaction message
        let isInvokeWrapped: Bool // Whether the transaction is wrapped already
        let publicKeySignaturePairs: [String: String] // Looks like: {[publicKey]: [signature]}. An object with the keys being public keys and the values being the signatures signing with the private keys
        let appendTx: [String: String] // Looks like: {[txId] => [signature]}. An object with the keys being the uuids of the transactions and the values being the signature
    }

    struct PostRequestResponse: Decodable {
        let status: ResponseStatus

        private enum CodingKeys: String, CodingKey {
            case status
            case authorizationId
            case reason
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let value = try container.decode(String.self, forKey: .status)
            switch value {
            case "PENDING":
                let signatureId = try container.decode(String.self, forKey: .authorizationId)
                self.status = .pending(signatureId: signatureId)
            case "DECLINED":
                let reason = try container.decode(String.self, forKey: .reason)
                self.status = .declined(reason: reason)
            default:
                throw DecodingError.typeMismatch(
                    String.self,
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "We only support 'PENDING' and 'DECLINED' for status, but get \(value)")
                )
            }
        }
    }

    enum ResponseStatus: Decodable {
        case pending(signatureId: String)
        case declined(reason: String)
    }

}
