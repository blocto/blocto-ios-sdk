//
//  AuthenticateMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/7/7.
//

import Foundation

public struct AuthenticateMethod: CallbackMethod {
    public typealias Response = (address: String, accountProof: [FlowCompositeSignature])

    public let id: UUID
    public let type: String = FlowMethodType.authenticate.rawValue
    public let callback: Callback

    let blockchain: Blockchain = .flow
    let accountProofData: FlowAccountProofData?

    /// initialize request account method
    /// - Parameters:
    ///   - id: Used to find a stored callback. No need to pass if there is no specific requirement, for example, testing.
    ///   - callback: callback will be called by either from blocto native app or web SDK after getting account or reject.
    public init(
        id: UUID = UUID(),
        accountProofData: FlowAccountProofData?,
        callback: @escaping Callback
    ) {
        self.id = id
        self.accountProofData = accountProofData
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
        queryItems.append(
            QueryItem(
                name: .method,
                value: type
            )
        )
        if let accountProofData = accountProofData {
            queryItems.append(contentsOf: [
                QueryItem(
                    name: .flowAppId,
                    value: accountProofData.appId
                ),
                QueryItem(
                    name: .flowNonce,
                    value: accountProofData.nonce
                ),
            ])
        }
        components.queryItems = URLEncoding.encode(queryItems)
        return components.url
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
        let signatures = components.getSignatures(type: .accountProof)
        callback(.success((address: address, accountProof: signatures)))
    }

    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}
