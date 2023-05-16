//
//  RequestAccountMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

public struct RequestAccountMethod: CallbackMethod {
    public typealias Response = (address: String, sessionId: String?)

    public let id: UUID
    public let type: String = MethodName.requestAccount.rawValue
    public let callback: Callback

    let blockchain: Blockchain

    /// initialize request account method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - blockchain: pre-defined blockchain in BloctoSDK
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    ///
    /// Supports for request account only in Flow Blockchain.
    /// For receiving account proof along with request account use AuthenticateMethod instead.
    public init(
        id: UUID = UUID(),
        blockchain: Blockchain,
        callback: @escaping Callback
    ) {
        self.id = id
        self.blockchain = blockchain
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
        queryItems.append(QueryItem(name: .method, value: type))
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
        guard let baseURL = URL(string: baseURLString) else {
            throw BloctoSDKError.urlNotFound
        }
        let newURL = baseURL
            .appendingPathComponent(appId)
            .appendingPathComponent(blockchain.rawValue)
            .appendingPathComponent("authn")
        guard var components = URLComponents(url: newURL, resolvingAgainstBaseURL: true) else {
            throw BloctoSDKError.urlComponentsNotFound
        }
        let queryItems = URLEncoding.queryGeneralWebItems(
            requestId: id.uuidString
        )
        components.queryItems = URLEncoding.encode(queryItems)
        guard let finalURL = components.url else {
            throw BloctoSDKError.urlNotFound
        }
        return finalURL
    }

    public func resolve(components: URLComponents, logging: Bool) {
        if let errorCode = components.queryItem(for: .error) {
            callback(.failure(BloctoSDKError(code: errorCode)))
            return
        }
        let targetQueryName = QueryName.address
        guard let address = components.queryItem(for: targetQueryName) else {
            log(
                enable: logging,
                message: "\(targetQueryName.rawValue) not found."
            )
            callback(.failure(BloctoSDKError.invalidResponse))
            return
        }
        let sessionId = components.queryItem(for: .sessionId)
        callback(.success((address: address, sessionId: sessionId)))
    }

    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}
