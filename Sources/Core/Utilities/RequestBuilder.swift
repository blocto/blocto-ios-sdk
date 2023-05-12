//
//  RequestBuilder.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/8/19.
//

import Foundation

enum RequestBuilder {

    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    static func build<Value>(
        baseURLString: String,
        path: String,
        method: Method,
        bodyParam: Value?
    ) throws -> URLRequest where Value: Encodable {
        guard let requestURL = URL(string: baseURLString + path) else {
            throw BloctoSDKError.urlNotFound
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        if let body = bodyParam {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(body)
            request.httpBody = encodedData
        }
        return request
    }

    /// Used for building request
    /// - Parameters:
    ///   - method: The request method
    ///   - methodId: The identifier for this method
    ///   - sessionId: The session_id we got after signing in
    ///   - baseURLString: The root endpoint of API
    ///   - path: The path for request
    ///   - body: The body of request
    /// - Returns: An URLRequest
    static func buildRequest(
        method: Method,
        methodId: String,
        sessionId: String,
        baseURLString: String,
        path: String,
        body: Encodable?
    ) throws -> URLRequest {
        guard let requestURL = URL(string: baseURLString + path) else {
            throw BloctoSDKError.urlNotFound
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        if case .post = method {
            request.allHTTPHeaderFields = [
                "Blocto-Session-Identifier": sessionId,
                "Blocto-Request-Identifier": methodId,
                "Blocto-Request-Source": "sdk_ios",
                "Content-Type": "application/json",
            ]
        }
        if let body = body {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(body)
            request.httpBody = encodedData
        }
        return request
    }

}
