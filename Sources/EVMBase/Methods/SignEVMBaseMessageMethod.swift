//
//  SignEVMBaseMessageMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/20.
//

import Foundation

public struct SignEVMBaseMessageMethod: CallbackMethod {

    public typealias Response = String

    public let id: UUID
    public let type: String = EVMBaseMethodType.signMessage.rawValue
    public let callback: Callback

    let blockchain: Blockchain
    let from: String
    let message: String
    let signType: EVMBaseSignType

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
        signType: EVMBaseSignType,
        blockchain: Blockchain,
        callback: @escaping SignEVMBaseMessageMethod.Callback
    ) {
        self.id = id
        self.from = from
        self.message = message
        self.signType = signType
        self.blockchain = blockchain
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
            blockchain: blockchain)
        queryItems.append(contentsOf: [
            QueryItem(name: .method, value: type),
            QueryItem(name: .from, value: from),
            QueryItem(name: .signType, value: signType.rawValue)
        ])
        let messageValue: String
        switch signType {
        case .sign:
            // input might be hexed string or normal string
            if message.hasPrefix("0x"),
               message
                .bloctoSDK.drop0x
                .bloctoSDK.hexDecodedData.isEmpty == false {
                messageValue = message.bloctoSDK.add0x
            } else {
                throw BloctoSDKError.ethSignInvalidHexString
            }
        case .personalSign:
            // input is string format
            messageValue = message
        case .typedSignV3,
                .typedSignV4,
                .typedSign:
            // input should be json format
            messageValue = message
        }
        queryItems.append(QueryItem(name: .message, value: messageValue))
        components.queryItems = URLEncoding.encode(queryItems)
        return components.url
    }

    public func resolve(components: URLComponents, logging: Bool) {
        if let errorCode = components.queryItem(for: .error) {
            callback(.failure(BloctoSDKError(code: errorCode)))
            return
        }
        let targetQueryName = QueryName.signature
        guard let signature = components.queryItem(for: targetQueryName) else {
            log(
                enable: logging,
                message: "\(targetQueryName.rawValue) not found.")
            callback(.failure(BloctoSDKError.invalidResponse))
            return
        }
        callback(.success(signature))
    }

    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}
