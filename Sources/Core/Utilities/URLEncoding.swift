//
//  URLEncoding.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/21.
//

import Foundation

enum URLEncoding {

    static func sharedQueryItem(
        appId: String,
        requestId: String,
        blockchain: Blockchain,
        method: String
    ) -> [QueryItem] {
        [
            QueryItem(name: .appId, value: appId),
            QueryItem(name: .requestId, value: requestId),
            QueryItem(name: .blockchain, value: blockchain),
            QueryItem(name: .method, value: method)
        ]
    }

    static func encode(_ queryItems: [QueryItem]) -> [URLQueryItem] {
        queryItems.flatMap { $0.getQueryComponents }
    }

}

struct ArrayEncoding {

    func encode(key: String) -> String {
        "\(key)[]"
    }

}

struct BoolEncoding {

    func encode(value: Bool) -> String {
        value ? "true" : "false"
    }

}

extension CharacterSet {
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    public static let afURLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()

}
