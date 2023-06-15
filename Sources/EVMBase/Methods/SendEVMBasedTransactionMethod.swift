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
    public let sessionId: String?
    public let type: String = EVMBaseMethodType.sendTransaction.rawValue
    public let callback: Callback

    let blockchain: Blockchain
    let transaction: EVMBaseTransaction
    let session: URLSessionProtocol

    /// initialize request account method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - sessionId: The session id for web browsing, so if request the account is from native Blocto App then this should be nil.
    ///   - blockchain: pre-defined blockchain in BloctoSDK
    ///   - transaction: The transaction structure describe the EVM base transaction.
    ///   - session: The session dependency injection for testing.
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        sessionId: String?,
        blockchain: Blockchain,
        transaction: EVMBaseTransaction,
        session: URLSessionProtocol = URLSession.shared,
        callback: @escaping Callback
    ) {
        self.id = id
        self.sessionId = sessionId
        self.blockchain = blockchain
        self.transaction = transaction
        self.session = session
        self.callback = callback
    }

    public func encodeToNativeURL(appId: String, baseURLString: String) throws -> URL? {
        guard let baseURL = URL(string: baseURLString),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        var queryItems = URLEncoding.queryGeneralItems(
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

    /// To support Blocto SDK API v2 endpoint
    /// - Parameters:
    ///   - appId: Registed id in https://developers.blocto.app/
    ///   - baseURLString: API v2 endpoint
    /// - Returns: URL for v2
    public func converToWebURLRequest(
        appId: String,
        baseURLString: String
    ) async throws -> URL {
        guard let sessionId else {
            throw BloctoSDKError.sessionIdNotProvided
        }
        let reqeustBody = RequestBody(
            from: transaction.from,
            to: transaction.to,
            value: String(transaction.value, radix: 16).bloctoSDK.add0x,
            data: transaction.data.bloctoSDK.hexStringWith0xPrefix,
            gas: transaction.gas?.description,
            maxPriorityFeePerGas: transaction.maxPriorityFeePerGas?.description,
            maxFeePerGas: transaction.maxFeePerGas?.description
        )
        let request = try RequestBuilder.buildRequest(
            method: .post,
            methodId: id.uuidString,
            sessionId: sessionId,
            baseURLString: baseURLString,
            path: "api/\(blockchain.rawValue)/dapp/authz",
            body: [reqeustBody]
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
        guard let requestId = components.queryItem(for: .requestId),
              requestId == id.uuidString else {
            log(
                enable: logging,
                message: "\(QueryName.requestId.rawValue) not matched with \(id.uuidString)"
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

extension SendEVMBasedTransactionMethod {

    struct RequestBody: Encodable {
        let from: String // The address for the sending account
        let to: String? // The destination address of the message, left undefined for a contract-creation transaction
        let value: String? // Hex string with '0x' prefix. The value transferred for the transaction in wei, also the endowment if it’s a contract-creation transaction
        let data: String? // Either a ABI byte string containing the data of the function call on a contract, or in the case of a contract-creation transaction the initialisation code
        let gas: String? // The amount of gas to use for the transaction
        let maxPriorityFeePerGas: String? // The maximum fee per gas to give miners to incentivize them to include the transaction
        let maxFeePerGas: String? // The maximum fee per gas that the transaction is willing to pay in total
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
