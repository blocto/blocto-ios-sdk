//
//  SendTransactionTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/5/16.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import BloctoSDK
import BigInt

class SendTransactionTests: XCTestCase {
    
    let platform = "sdk_ios"
    var mockUIApplication: MockUIApplication!

    override func setUp() {
        super.setUp()
        mockUIApplication = MockUIApplication()
    }

    func testSendTransactionEncodeURL() throws {
        // Given:
        let requestId = UUID()
        let sessionId = "555E7A3D-77AA-4DDF-B72D-A20AD5C0D41B"

        let to = "0x58F385777aa6699b81f741Dd0d5B272A34C1c774"
        let from = "0xC823994cDDdaE5cb4bD1ADFe5AfD03f8E06Bc7ef"
        let value: BigUInt = 123
        let dataString = "5524107700000000000000000000000000000000000000000000000000000000000015be"

        let evmBaseTransaction = EVMBaseTransaction(
            from: from,
            to: to,
            value: value,
            data: dataString.bloctoSDK.hexDecodedData
        )

        let sendTransactionMethod = SendEVMBasedTransactionMethod(
            id: requestId,
            sessionId: sessionId,
            blockchain: .ethereum,
            transaction: evmBaseTransaction
        ) { _ in }

        let baseURLString = BloctoSDK.shared.requestBloctoBaseURLString

        var expectedURLComponents = URLComponents(string: baseURLString)
        expectedURLComponents?.queryItems = [
            URLQueryItem(name: .appId, value: appId),
            URLQueryItem(name: .requestId, value: requestId.uuidString),
            URLQueryItem(name: .blockchain, value: Blockchain.ethereum.rawValue),
            URLQueryItem(name: .method, value: EVMBaseMethodType.sendTransaction.rawValue),
            URLQueryItem(name: .from, value: from),
            URLQueryItem(name: .to, value: to),
            URLQueryItem(name: .value, value: "0x7b"),
            URLQueryItem(name: .data, value: "0x" + dataString),
            URLQueryItem(name: .platform, value: platform)
        ]

        // When:
        let url = try sendTransactionMethod.encodeToURL(
            appId: appId,
            baseURLString: baseURLString
        )

        // Then:
        XCTAssertURLEqual(url, expectedURLComponents?.url, "URL should be \(expectedURLComponents?.url?.absoluteString ?? "") rather then \(url?.absoluteString ?? "")")
    }

    func testOpenNativeAppWhenInstalled() throws {
        // Given:
        let requestId = UUID()
        var txHash: String?
        let expectedTxHash: String = "0xe608645ba741c8064a2990c16b395c5b1377c7e1f8683b9319052560f89d279e"
        BloctoSDK.shared.initialize(
            with: appId,
            getWindow: { UIWindow() },
            logging: false,
            environment: .dev,
            urlOpening: mockUIApplication
        )

        mockUIApplication.setup(openedOrder: [true])

        let evmBaseTransaction = EVMBaseTransaction(
            from: "0xC823994cDDdaE5cb4bD1ADFe5AfD03f8E06Bc7ef",
            to: "0x58F385777aa6699b81f741Dd0d5B272A34C1c774",
            value: 100,
            data: "b5aebc80000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000066c616c616c610000000000000000000000000000000000000000000000000000".bloctoSDK.hexDecodedData
        )

        // When:
        BloctoSDK.shared.evm.sendTransaction(
            uuid: requestId,
            blockchain: .ethereum,
            transaction: evmBaseTransaction
        ) { result in
            switch result {
            case let .success(receivedtxHash):
                txHash = receivedtxHash
            case let .failure(error):
                XCTAssert(false, error.localizedDescription)
            }
        }

        var components = URLComponents(string: appCustomSchemeBaseURLString)
        components?.queryItems = [
            .init(name: "request_id", value: requestId.uuidString),
            .init(name: "tx_hash", value: expectedTxHash)
        ]
        BloctoSDK.shared.application(
            open: components!.url!
        )

        // Then:
        XCTAssert(txHash == expectedTxHash, "txHash should be \(expectedTxHash) rather then \(txHash!)")

    }

    func testOpenWebSDK() throws {
        // Given:
        let requestId = UUID()
        var txHash: String?
        let expectedTxHash: String = "0xe608645ba741c8064a2990c16b395c5b1377c7e1f8683b9319052560f89d279e"

        BloctoSDK.shared.initialize(
            with: appId,
            getWindow: { UIWindow() },
            logging: false,
            environment: .dev,
            urlOpening: mockUIApplication,
            sessioningType: MockAuthenticationSession.self
        )

        mockUIApplication.setup(openedOrder: [false])

        let evmBaseTransaction = EVMBaseTransaction(
            from: "0xC823994cDDdaE5cb4bD1ADFe5AfD03f8E06Bc7ef",
            to: "0x58F385777aa6699b81f741Dd0d5B272A34C1c774",
            value: 100,
            data: "b5aebc80000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000066c616c616c610000000000000000000000000000000000000000000000000000".bloctoSDK.hexDecodedData
        )

        var components = URLComponents(string: webRedirectBaseURLString)
        components?.queryItems = [
            .init(name: "request_id", value: requestId.uuidString),
            .init(name: "tx_hash", value: expectedTxHash)
        ]
        MockAuthenticationSession.setCallbackURL(components!.url!)

        // When:
        BloctoSDK.shared.evm.sendTransaction(
            uuid: requestId,
            blockchain: .ethereum,
            transaction: evmBaseTransaction
        ) { result in
            switch result {
            case let .success(receivedtxHash):
                txHash = receivedtxHash
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        // Then:
        XCTAssert(txHash == expectedTxHash, "txHash should be \(expectedTxHash) rather then \(txHash!)")
    }

}
