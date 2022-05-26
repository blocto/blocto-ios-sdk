//
//  ParsedMethodTests.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/3/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import BloctoSDK

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
            QueryName.method.rawValue: MethodName.requestAccount.rawValue
        ]

        let expected = ParsedMethod(
            appId: appId,
            requestId: requestId,
            blockchain: .solana,
            methodContentType: .solana(.requestAccount))

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
        && lhs.methodContentType == rhs.methodContentType
    }

}

extension GeneralMethodContentType: Equatable {

    public static func == (lhs: GeneralMethodContentType, rhs: GeneralMethodContentType) -> Bool {
        switch (lhs, rhs) {
        case let (.solana(lSolanaMethodContentType), .solana(rSolanaMethodContentType)):
            return lSolanaMethodContentType == rSolanaMethodContentType
        case let (.evmBase(lEVMBaseMethodContentType), .evmBase(rEVMBaseMethodContentType)):
            return lEVMBaseMethodContentType == rEVMBaseMethodContentType
        default:
            return false
        }
    }

}

extension SolanaMethodContentType: Equatable {

    public static func == (lhs: SolanaMethodContentType, rhs: SolanaMethodContentType) -> Bool {
        switch (lhs, rhs) {
        case (.requestAccount, .requestAccount):
            return true
        case let (.signAndSendTransaction(lFrom,
                                          lIsInvokeWrapped,
                                          lTransactionInfo),
                  .signAndSendTransaction(rFrom,
                                          rIsInvokeWrapped,
                                          rTransactionInfo)):
            return lFrom == rFrom
            && lIsInvokeWrapped == rIsInvokeWrapped
            && lTransactionInfo == rTransactionInfo
        default:
            return false
        }
    }

}

extension EVMBaseMethodContentType: Equatable {

    public static func == (lhs: EVMBaseMethodContentType, rhs: EVMBaseMethodContentType) -> Bool {
        switch (lhs, rhs) {
        case (.requestAccount, .requestAccount):
            return true
        case let (.signMessage(lFrom,
                               lMessage,
                               lSignType),
                  .signMessage(rFrom,
                               rMessage,
                               rSignType)):
            return lFrom == rFrom
            && lMessage == rMessage
            && lSignType == rSignType
        case let (.sendTransaction(lTransaction),
                  .sendTransaction(rTransaction)):
            return lTransaction == rTransaction
        default:
            return false
        }
    }

}

extension SolanaTransactionInfo: Equatable {

    public static func == (lhs: SolanaTransactionInfo, rhs: SolanaTransactionInfo) -> Bool {
        lhs.message == rhs.message
        && lhs.appendTx == rhs.appendTx
        && lhs.publicKeySignaturePairs == rhs.publicKeySignaturePairs
    }

}

extension EVMBaseTransaction: Equatable {

    public static func == (lhs: EVMBaseTransaction, rhs: EVMBaseTransaction) -> Bool {
        lhs.to == rhs.to
        && lhs.from == rhs.from
        && lhs.value == rhs.value
        && lhs.data == rhs.data
    }

}
