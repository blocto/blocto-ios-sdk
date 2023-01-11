//
//  SignFlowMessageMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/13.
//

import Foundation

public struct SignFlowMessageMethod: CallbackMethod {

    public typealias Response = [FlowCompositeSignature]

    public let id: UUID
    public let type: String = FlowMethodType.userSignature.rawValue
    public let callback: Callback

    let blockchain: Blockchain = .flow
    let from: String
    let message: String

    /// initialize sign EVMBase message method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - from: send from which address.
    ///   - message: message needs to be sign in String format.
    ///   - signType: pre-defined signType in BloctoSDK/EVMBase
    ///   - blockchain: pre-defined blockchain in BloctoSDK
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        from: String,
        message: String,
        callback: @escaping SignFlowMessageMethod.Callback
    ) {
        self.id = id
        self.from = from
        self.message = message
        self.callback = callback
    }

    public func encodeToURL(appId: String, baseURLString: String) throws -> URL? {
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
            QueryItem(name: .from, value: from),
        ])
        queryItems.append(QueryItem(name: .message, value: message))
        components.queryItems = URLEncoding.encode(queryItems)
        return components.url
    }

    public func resolve(components: URLComponents, logging: Bool) {
        if let errorCode = components.queryItem(for: .error) {
            callback(.failure(BloctoSDKError(code: errorCode)))
            return
        }
        let signatures = components.getSignatures(type: .userSignature)
        callback(.success(signatures))
    }

    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}
