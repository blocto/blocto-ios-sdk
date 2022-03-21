//
//  RequestAccountMethod.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

public struct RequestAccountMethod: CallbackMethod {
    public typealias Response = String
    
    public let id: UUID
    public let type: MethodType = .requestAccount
    public let callback: Callback
    
    let blockchain: Blockchain
    
    public init(
        id: UUID = UUID(),
        blockchain: Blockchain,
        callback: @escaping Callback
    ) {
        self.id = id
        self.blockchain = blockchain
        self.callback = callback
    }
    
    public func encodeToURL(domainWithPath: String) throws -> URL? {
        guard let baseURL = URL(string: domainWithPath),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
                  return nil
              }
        let queryItems = BloctoSDK.shared.sharedQueryItem(
            appId: BloctoSDK.shared.appId,
            requestId: id.uuidString,
            blockchain: blockchain,
            method: type.rawValue)
        components.queryItems = BloctoSDK.shared.encode(queryItems)
        return components.url
    }
    
    public func resolve(components: URLComponents) {
        if let errorCode = components.queryItem(for: .error) {
            callback(.failure(QueryError(code: errorCode)))
            return
        }
        guard let address = components.queryItem(for: .address) else {
            BloctoSDK.shared.log(message: "\(QueryName.address.rawValue) not found.")
            callback(.failure(QueryError.invalidResponse))
            return
        }
        callback(.success(address))
    }
    
    public func handleError(error: Swift.Error) {
        callback(.failure(error))
    }
}
