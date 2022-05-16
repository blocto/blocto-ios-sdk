////
////  QueryItemEncodingTests.swift
////  BloctoSDK_Tests
////
////  Created by Andrew Wang on 2022/4/6.
////  Copyright © 2022 CocoaPods. All rights reserved.
////
//
// import XCTest
// @testable import BloctoSDK
// import BigInt
//
// class QueryItemEncodingTests: XCTestCase {
//
//    func testDictionaryEncoding() throws {
//        // Given:
//        let queryItem = QueryItem(
//            name: QueryName.publicKeySignaturePairs,
//            value: [
//                "test1": "1",
//                "test2": "2"
//            ])
//        let expect: [URLQueryItem] = [
//            URLQueryItem(name: QueryName.publicKeySignaturePairs.rawValue + "%5Btest1%5D", value: "1"),
//            URLQueryItem(name: QueryName.publicKeySignaturePairs.rawValue + "%5Btest2%5D", value: "2")
//        ]
//
//        // When:
//        let queryComponents = queryItem.getQueryComponents
//
//        // Then:
//        XCTAssertArrayElementsEqual(queryComponents, expect)
//    }
//
//    func testDictionaryDecoding() throws {
//        // Given:
//        let param = [
//            QueryName.publicKeySignaturePairs.rawValue + "%5Btest1%5D": "1",
//            QueryName.publicKeySignaturePairs.rawValue + "%5Btest2%5D": "2"
//        ]
//
//        let expect: [String: String] = [
//            "test1": "1",
//            "test2": "2"
//        ]
//
//        // When:
//        let dictionary: [String: String] = QueryDecoding.decodeDictionary(
//            param: param,
//            queryName: .publicKeySignaturePairs)
//
//        // Then:
//        XCTAssertDictionaryEqual(dictionary, expect)
//    }
//
//    func testDictionaryDataEncoding() throws {
//        // Given:
//        let data1 = "1234".hexDecodedData
//        let data2 = "2345".hexDecodedData
//        let queryItem = QueryItem(
//            name: QueryName.appendTx,
//            value: [
//                "test1": data1,
//                "test2": data2
//            ])
//        let expect: [URLQueryItem] = [
//            URLQueryItem(name: QueryName.appendTx.rawValue + "%5Btest1%5D", value: "1234"),
//            URLQueryItem(name: QueryName.appendTx.rawValue + "%5Btest2%5D", value: "2345")
//        ]
//
//        // When:
//        let queryComponents = queryItem.getQueryComponents
//
//        // Then:
//        XCTAssertArrayElementsEqual(queryComponents, expect)
//    }
//
//    func testDictionaryDataDecoding() throws {
//        // Given:
//        let param = [
//            QueryName.appendTx.rawValue + "%5Btest1%5D": "1234",
//            QueryName.appendTx.rawValue + "%5Btest2%5D": "2345"
//        ]
//
//        let expect: [String: Data] = [
//            "test1": "1234".hexDecodedData,
//            "test2": "2345".hexDecodedData
//        ]
//
//        // When:
//        let dictionary: [String: Data] = QueryDecoding.decodeDictionary(
//            param: param,
//            queryName: .appendTx)
//
//        // Then:
//        XCTAssertDictionaryEqual(dictionary, expect)
//    }
//
//    func testEVMBaseTransactionValueEncoding() throws {
//        // Given:
//        let requestId: String = "FB09703B-7D29-44C6-BEB6-7C0FBEA0D585"
//        let blockchain: Blockchain = .ethereum
//        let to = "0x58F385777aa6699b81f741Dd0d5B272A34C1c774"
//        let from = "0xC823994cDDdaE5cb4bD1ADFe5AfD03f8E06Bc7ef"
//        let value = BigUInt(256)
//        let dataString = "5524107700000000000000000000000000000000000000000000000000000000000015be"
//        let evmBaseTransaction: EVMBaseTransaction = .init(
//            to: to,
//            from: from,
//            value: value,
//            data: dataString.hexDecodedData)
//        let methodContentType: MethodContentType = .sendTransaction(transaction: evmBaseTransaction)
//
//        let expect: [URLQueryItem] = [
//            URLQueryItem(name: QueryName.appId.rawValue, value: appId),
//            URLQueryItem(name: QueryName.requestId.rawValue, value: requestId),
//            URLQueryItem(name: QueryName.blockchain.rawValue, value: blockchain.rawValue),
//            URLQueryItem(name: QueryName.method.rawValue, value: MethodType.sendTransaction.rawValue),
//            URLQueryItem(name: QueryName.from.rawValue, value: from),
//            URLQueryItem(name: QueryName.to.rawValue, value: to),
//            URLQueryItem(name: QueryName.value.rawValue, value: "100"),
//            URLQueryItem(name: QueryName.data.rawValue, value: dataString)
//        ]
//
//        // When:
//        let queryItems = URLEncoding.queryItems(
//            appId: appId,
//            requestId: requestId,
//            blockchain: blockchain,
//            method: methodContentType)
//        let queryComponents = URLEncoding.encode(queryItems)
//
//        // Then:
//        XCTAssertArrayElementsEqual(queryComponents, expect)
//    }
//
// }
