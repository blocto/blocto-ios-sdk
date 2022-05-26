//
//  QueryItemEncodingTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/4/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

 import XCTest
 @testable import BloctoSDK
 import BigInt

 class QueryItemEncodingTests: XCTestCase {

    func testDictionaryEncoding() throws {
        // Given:
        let queryItem = QueryItem(
            name: QueryName.publicKeySignaturePairs,
            value: [
                "test1": "1",
                "test2": "2"
            ])
        let expect: [URLQueryItem] = [
            URLQueryItem(name: QueryName.publicKeySignaturePairs.rawValue + "%5Btest1%5D", value: "1"),
            URLQueryItem(name: QueryName.publicKeySignaturePairs.rawValue + "%5Btest2%5D", value: "2")
        ]

        // When:
        let queryComponents = queryItem.getQueryComponents

        // Then:
        XCTAssertArrayElementsEqual(queryComponents, expect)
    }

    func testDictionaryDecoding() throws {
        // Given:
        let param = [
            QueryName.publicKeySignaturePairs.rawValue + "%5Btest1%5D": "1",
            QueryName.publicKeySignaturePairs.rawValue + "%5Btest2%5D": "2"
        ]

        let expect: [String: String] = [
            "test1": "1",
            "test2": "2"
        ]

        // When:
        let dictionary: [String: String] = QueryDecoding.decodeDictionary(
            param: param,
            queryName: .publicKeySignaturePairs)

        // Then:
        XCTAssertDictionaryEqual(dictionary, expect)
    }

    func testDictionaryDataEncoding() throws {
        // Given:
        let data1 = "1234".bloctoSDK.hexDecodedData
        let data2 = "2345".bloctoSDK.hexDecodedData
        let queryItem = QueryItem(
            name: QueryName.appendTx,
            value: [
                "test1": data1,
                "test2": data2
            ])
        let expect: [URLQueryItem] = [
            URLQueryItem(name: QueryName.appendTx.rawValue + "%5Btest1%5D", value: "0x1234"),
            URLQueryItem(name: QueryName.appendTx.rawValue + "%5Btest2%5D", value: "0x2345")
        ]

        // When:
        let queryComponents = queryItem.getQueryComponents

        // Then:
        XCTAssertArrayElementsEqual(queryComponents, expect)
    }

    func testDictionaryDataDecoding() throws {
        // Given:
        let param = [
            QueryName.appendTx.rawValue + "%5Btest1%5D": "1234",
            QueryName.appendTx.rawValue + "%5Btest2%5D": "2345"
        ]

        let expect: [String: Data] = [
            "test1": "1234".bloctoSDK.hexDecodedData,
            "test2": "2345".bloctoSDK.hexDecodedData
        ]

        // When:
        let dictionary: [String: Data] = QueryDecoding.decodeDictionary(
            param: param,
            queryName: .appendTx)

        // Then:
        XCTAssertDictionaryEqual(dictionary, expect)
    }

 }
