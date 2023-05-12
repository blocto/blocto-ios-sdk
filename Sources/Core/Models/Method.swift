//
//  Method.swift
//  Alamofire
//
//  Created by Andrew Wang on 2022/3/14.
//

import Foundation

public protocol Method {
    var id: UUID { get }
    var type: String { get }

    func encodeToURL(appId: String, baseURLString: String) throws -> URL?
//    func encodeToWebURLRequest(appId: String, baseURLString: String) throws -> URLRequest?
//    func handlePostRequest(_ urlRequest: URLRequest) async throws -> URL
    func converToWebURLRequest(
        appId: String,
        baseURLString: String
    ) async throws -> URL
    func resolve(components: URLComponents, logging: Bool)
    func handleError(error: Swift.Error)
}

extension Method {

//    @available(*, deprecated, message: "should be deleted")
//    public func encodeToWebURLRequest(appId: String, baseURLString: String) throws -> URLRequest? {
//        throw BloctoSDKError.urlNotFound
//    }
//
//    public func handlePostRequest(_ urlRequest: URLRequest) async throws -> URL {
//        throw BloctoSDKError.functionNotImplemented
//    }

    @available(*, deprecated, message: "should be deleted")
    public func converToWebURLRequest(
        appId: String,
        baseURLString: String
    ) async throws -> URL {
        throw BloctoSDKError.functionNotImplemented
    }

}
