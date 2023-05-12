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
    public let sessionId: String?
    public let type: String = EVMBaseMethodType.signMessage.rawValue
    public let callback: Callback

    let blockchain: Blockchain
    let from: String
    let message: String
    let signType: EVMBaseSignType

    /// initialize sign EVMBase message method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - sessionId: The session id for web browsing, so if request the account is from native Blocto App then this should be nil.
    ///   - from: send from which address.
    ///   - message: message needs to be sign in String format.
    ///   - signType: pre-defined signType in BloctoSDK/EVMBase
    ///   - blockchain: pre-defined blockchain in BloctoSDK
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        sessionId: String?,
        from: String,
        message: String,
        signType: EVMBaseSignType,
        blockchain: Blockchain,
        callback: @escaping SignEVMBaseMessageMethod.Callback
    ) {
        self.id = id
        self.sessionId = sessionId
        self.from = from
        self.message = message
        self.signType = signType
        self.blockchain = blockchain
        self.callback = callback
    }

    /// Only used for native routing.
    /// - Parameters:
    ///   - appId: Registed id in https://developers.blocto.app/
    ///   - baseURLString: The base URL string for universal link of Blocto App
    /// - Returns: URL for universal link of Blocto App
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
            QueryItem(name: .signType, value: signType.rawValue),
        ])
        let messageValue: String
        switch signType {
        case .sign:
            // input might be hexed string or normal string
            if message.hasPrefix("0x"),
               message
               .bloctoSDK.drop0x
               .bloctoSDK.hexDecodedData.isEmpty == false {
                messageValue = message
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

    /// To support Blocto SDK API v2 endpoint
    /// - Parameters:
    ///   - appId: Registed id in https://developers.blocto.app/
    ///   - baseURLString: API v2 endpoint
    /// - Returns: URL for v2
//    public func encodeToWebURLRequest(appId: String, baseURLString: String) throws -> URLRequest? {
//        guard let baseURL = URL(string: baseURLString) else {
//            return nil
//        }
//        let newURL = baseURL
//            .appendingPathComponent(appId)
//            .appendingPathComponent(blockchain.rawValue)
//            .appendingPathComponent("dapp")
//            .appendingPathComponent("user-signature")
//        guard let components = URLComponents(url: newURL, resolvingAgainstBaseURL: true),
//              let url = components.url else {
//            return nil
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = RequestBuilder.Method.post.rawValue
//        return request
//    }

    /// Only handle request method is POST
    /// - Parameter urlRequest: The request from encodeToWebURLRequest
    /// - Returns: The url which the webview should browse
//    public func handlePostRequest(_ urlRequest: URLRequest) async throws -> URL {
//        let reqeustBody = RequestBody(
//            from: from,
//            message: message,
//            method: signType.rawValue
//        )
//        let request = try RequestBuilder.buildRequest(
//            baseURLString: BloctoSDK.shared.webBaseURLString,
//            path: "api/\(blockchain.rawValue)/dapp/user-signature",
//            method: .post,
//            body: reqeustBody
//        )
//        let response: PostRequestResponse = try await URLSession.shared.asyncDataTask(with: request)
//        switch response.status {
//        case let .pending(signatureId):
//            guard let baseURL = URL(string: BloctoSDK.shared.webBaseURLString) else {
//                throw BloctoSDKError.urlNotFound
//            }
//            let newURL = baseURL
//                .appendingPathComponent(BloctoSDK.shared.appId)
//                .appendingPathComponent(blockchain.rawValue)
//                .appendingPathComponent("user-signature")
//                .appendingPathComponent(signatureId)
//            guard let components = URLComponents(url: newURL, resolvingAgainstBaseURL: true),
//                  let url = components.url else {
//                throw BloctoSDKError.urlNotFound
//            }
//            return url
//        case let .declined(reason):
//            throw BloctoSDKError.postRequestFailed(reason: reason)
//        }
//    }

    /// To support Blocto SDK API v2 endpoint
    /// - Parameters:
    ///   - appId: Registed id in https://developers.blocto.app/
    ///   - baseURLString: API v2 endpoint
    /// - Returns: URL for v2
    public func converToWebURLRequest(
        appId: String,
        baseURLString: String
    ) async throws -> URL {
        guard let sessionId = sessionId else {
            throw BloctoSDKError.sessionIdNotProvided
        }
        let reqeustBody = RequestBody(
            from: from,
            message: message,
            method: signType.rawValue
        )
        let request = try RequestBuilder.buildRequest(
            method: .post,
            methodId: id.uuidString,
            sessionId: sessionId,
            baseURLString: baseURLString,
            path: "api/\(blockchain.rawValue)/dapp/user-signature",
            body: reqeustBody
        )
        let response: PostRequestResponse = try await URLSession.shared.asyncDataTask(with: request)
        switch response.status {
        case let .pending(signatureId):
            guard let baseURL = URL(string: baseURLString) else {
                throw BloctoSDKError.urlNotFound
            }
            let newURL = baseURL
                .appendingPathComponent(appId)
                .appendingPathComponent(blockchain.rawValue)
                .appendingPathComponent("user-signature")
                .appendingPathComponent(signatureId)
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
        let targetQueryName = QueryName.signature
        guard let signature = components.queryItem(for: targetQueryName) else {
            log(
                enable: logging,
                message: "\(targetQueryName.rawValue) not found."
            )
            callback(.failure(BloctoSDKError.invalidResponse))
            return
        }
        callback(.success(signature))
    }

    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}

extension SignEVMBaseMessageMethod {

    struct RequestBody: Encodable {
        let from: String // The user's address
        let message: String // The message to be signed and displayed to the user
        let method: String // Which type of the messgae we want to sign
    }

    struct PostRequestResponse: Decodable {
        let status: ResponseStatus

        private enum CodingKeys: String, CodingKey {
            case status
            case signatureId
            case reason
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let value = try container.decode(String.self, forKey: .status)
            switch value {
            case "PENDING":
                let signatureId = try container.decode(String.self, forKey: .signatureId)
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
