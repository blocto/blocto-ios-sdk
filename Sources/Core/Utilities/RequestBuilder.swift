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
        bodyParam: [String: Value]
    ) throws -> URLRequest where Value: Encodable {
        guard let requestURL = URL(string: BloctoSDK.shared.bloctoApiBaseURLString + path) else {
            throw BloctoSDKError.urlNotFound
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        if bodyParam.isEmpty == false {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(bodyParam)
            request.httpBody = encodedData
        }
        return request
    }

}
