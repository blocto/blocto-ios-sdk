//
//  QueryItemEncodingTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/4/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import BloctoSDK

class QueryItemEncodingTests: XCTestCase {

    func testDictionaryEncoding() throws {
        // Given:
        let queryItem = QueryItem(
            name: QueryName.extraPublicKeySignaturePairs,
            value: [
                "test1": "1",
                "test2": "2"
            ])
        let expect: [URLQueryItem] = [
            URLQueryItem(name: QueryName.extraPublicKeySignaturePairs.rawValue + "%5Btest1%5D", value: "1"),
            URLQueryItem(name: QueryName.extraPublicKeySignaturePairs.rawValue + "%5Btest2%5D", value: "2")
        ]

        // When:
        let queryComponents = queryItem.getQueryComponents

        // Then:
        XCTAssertArrayElementsEqual(queryComponents, expect)
    }

    func testDictionaryDecoding() throws {
        // Given:
        let param = [
            QueryName.extraPublicKeySignaturePairs.rawValue + "%5Btest1%5D": "1",
            QueryName.extraPublicKeySignaturePairs.rawValue + "%5Btest2%5D": "2"
        ]

        let expect: [String: String] = [
            "test1": "1",
            "test2": "2"
        ]

        // When:
        let dictionary = QueryDecoding.decodeDictionary(
            param: param,
            queryName: .extraPublicKeySignaturePairs)

        // Then:
        XCTAssertDictionaryEqual(dictionary, expect)
    }

}
