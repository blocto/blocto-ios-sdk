//
//  FlowMethodURLEncodeTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/10/17.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import Cadence
import FlowSDK
@testable import BloctoSDK

final class FlowMethodURLEncodeTests: XCTestCase {

    func testFlowRequestAccount() throws {
        // Given:
        let requestId = UUID()
        let method = RequestAccountMethod(
            id: requestId,
            blockchain: .flow
        ) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.flow.rawValue),
            URLQueryItem(name: .method, value: MethodName.requestAccount.rawValue),
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString
        ) else {
            XCTFail("requestURL not found.")
            return
        }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

    func testFlowAuthn() throws {
        // Given:
        let requestId = UUID()
        let method = AuthenticateMethod(id: requestId, accountProofData: nil) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.flow.rawValue),
            URLQueryItem(name: .method, value: FlowMethodType.authenticate.rawValue),
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString
        ) else {
            XCTFail("requestURL not found.")
            return
        }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

    func testFlowAuthnWithAccountProof() throws {
        // Given:
        let requestId = UUID()
        let appId = "test app id"
        let nonce = "75f8587e5bd5f9dcc9909d0dae1f0ac5814458b2ae129620502cb936fde7120a"
        let accountProofData = FlowAccountProofData(appId: appId, nonce: nonce)
        let method = AuthenticateMethod(id: requestId, accountProofData: accountProofData) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.flow.rawValue),
            URLQueryItem(name: .method, value: FlowMethodType.authenticate.rawValue),
            URLQueryItem(name: .flowAppId, value: appId),
            URLQueryItem(name: .flowNonce, value: nonce),
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString
        ) else {
            XCTFail("requestURL not found.")
            return
        }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

    func testFlowSignMethod() throws {
        // Given:
        let requestId = UUID()
        let address = "0x3546620f0b6b8421"

        let message: String = "this is test message"

        let method = SignFlowMessageMethod(
            id: requestId,
            from: address,
            message: message
        ) { _ in }

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.flow.rawValue),
            URLQueryItem(name: .method, value: FlowMethodType.userSignature.rawValue),
            URLQueryItem(name: .from, value: address),
            URLQueryItem(name: .message, value: message),
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString
        ) else {
            XCTFail("requestURL not found.")
            return
        }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

    func testFlowSendMethod() throws {
        let requestId = UUID()
        let addressString = "0x3546620f0b6b8421"
        let address = Address(hexString: addressString)
        let script = """
        import ValueDapp from VALUE_DAPP_CONTRACT

        transaction(value: UFix64) {
            prepare(authorizer: AuthAccount) {
                ValueDapp.setValue(value)
            }
        }
        """
        let transaction = try Transaction(
            script: Data(script.utf8),
            arguments: [
                Cadence.Argument(.ufix64(12)),
            ],
            referenceBlockId: Identifier(hexString: "2ee718f9151b8ec3d056ebdb79fc6a716825936ea9a6a26de4a7266930d675fd"),
            proposalKey: Transaction.ProposalKey(address: address, keyIndex: 0, sequenceNumber: 1),
            payer: address
        )
        let method = SendFlowTransactionMethod(
            id: requestId,
            from: address,
            transaction: transaction
        ) { _ in }

        let transactionDataHex = transaction.encode().bloctoSDK.hexString

        var expectURLComponents = URLComponents(string: BloctoSDK.shared.requestBloctoBaseURLString)
        expectURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.flow.rawValue),
            URLQueryItem(name: .method, value: FlowMethodType.sendTransaction.rawValue),
            URLQueryItem(name: .from, value: addressString),
            URLQueryItem(name: .flowTransaction, value: transactionDataHex),
        ]

        // When:
        guard let requestURL = try method.encodeToURL(
            appId: appId,
            baseURLString: BloctoSDK.shared.requestBloctoBaseURLString
        ) else {
            XCTFail("requestURL not found.")
            return
        }

        // Then:
        XCTAssertURLEqual(requestURL, expectURLComponents?.url)
    }

}
