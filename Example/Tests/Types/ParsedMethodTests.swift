//
//  ParsedMethodTests.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/3/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import BloctoSDK

class ParsedMethodTests: XCTestCase {

    private let appId = "64776cec-5953-4a58-8025-772f55a3917b"

    override func setUp() {
        super.setUp()
    }

    func testParseAccountRequest() {
        // Given:
        let requestId = UUID().uuidString
        let param: [String: String] = [
            QueryName.appId.rawValue: appId,
            QueryName.requestId.rawValue: requestId,
            QueryName.blockchain.rawValue: Blockchain.solana.rawValue,
            QueryName.method.rawValue: MethodType.requestAccount.rawValue
        ]

        let expected = ParsedMethod(
            appId: appId,
            requestId: requestId,
            blockchain: .solana,
            method: .requestAccount)

        // When:
        let parsedMethod = ParsedMethod(param: param)

        // Then:
        XCTAssertEqual(parsedMethod, expected)

    }

}

extension ParsedMethod: Equatable {

    public static func == (lhs: ParsedMethod, rhs: ParsedMethod) -> Bool {
        lhs.appId == rhs.appId
        && lhs.requestId == rhs.requestId
        && lhs.blockchain == rhs.blockchain
        && lhs.method == rhs.method
    }

}

extension MethodContentType: Equatable {

    public static func == (lhs: MethodContentType, rhs: MethodContentType) -> Bool {
        switch (lhs, rhs) {
            case (.requestAccount, .requestAccount):
                return true
            case let (.signMessage(lFrom, lMessage), .signMessage(rFrom, rMessage)):
                return lFrom == rFrom
                && lMessage == rMessage
            case let (.sendTransaction(lFrom, lMessage), .sendTransaction(rFrom, rMessage)):
                return lFrom == rFrom
                && lMessage == rMessage
            default:
                return false
        }
    }

}
