//
//  SignAndSendTransactionTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/4/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import BloctoSDK

class SignAndSendTransactionTests: XCTestCase {

    var mockUIApplication: MockUIApplication!

    let appId: String = "64776cec-5953-4a58-8025-772f55a3917b"
    let appUniversalLinkBaseURLString: String = "https://c161-61-216-44-25.ngrok.io/"
    let webRedirectBaseURLString: String = "blocto://"

    override func setUp() {
        super.setUp()
        mockUIApplication = MockUIApplication()
    }

    func testOpenNativeAppWhenInstalled() {
        // Given:
        let requestId = UUID()
        var txHash: String?
        let expectedTxHash: String = "65ZG7Retj1acmX2DXv9YdU12JJ53a5sKgBmmDGHVexTyDnFq8C3inKMMvcdMXi5NvZCLSueThdSNNHJBWdw7neUC"
        if #available(iOS 13.0, *) {
            BloctoSDK.shared.initialize(
                with: appId,
                window: UIWindow(),
                logging: false,
                urlOpening: mockUIApplication)
        } else {
            BloctoSDK.shared.initialize(
                with: appId,
                logging: false,
                urlOpening: mockUIApplication)
        }

        mockUIApplication.setup(opened: true)

        // When:
        let requestAccountMethod = SignAndSendSolanaTransactionMethod(
            id: requestId,
            blockchain: Blockchain.solana,
            from: "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv",
            message: "testMessage") { result in
                switch result {
                    case let .success(receivedtxHash):
                        txHash = receivedtxHash
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                }
            }
        BloctoSDK.shared.send(method: requestAccountMethod)

        var components = URLComponents(string: appUniversalLinkBaseURLString)
        components?.path = "/blocto"
        components?.queryItems = [
            .init(name: "request_id", value: requestId.uuidString),
            .init(name: "tx_hash", value: expectedTxHash)
        ]

        BloctoSDK.shared.application(
            UIApplication.shared,
            open: components!.url!,
            options: [:])

        // Then:
        XCTAssert(txHash == expectedTxHash, "txHash should be \(expectedTxHash) rather then \(txHash!)")

    }

    func testOpenWebSDK() {
        // Given:
        let requestId = UUID()
        var txHash: String?
        let expectedTxHash: String = "65ZG7Retj1acmX2DXv9YdU12JJ53a5sKgBmmDGHVexTyDnFq8C3inKMMvcdMXi5NvZCLSueThdSNNHJBWdw7neUC"
        if #available(iOS 13.0, *) {
            BloctoSDK.shared.initialize(
                with: appId,
                window: UIWindow(),
                logging: false,
                urlOpening: mockUIApplication,
                sessioningType: MockAuthenticationSession.self)
        } else {
            BloctoSDK.shared.initialize(
                with: appId,
                logging: false,
                urlOpening: mockUIApplication,
                sessioningType: MockAuthenticationSession.self)
        }

        mockUIApplication.setup(opened: false)

        var components = URLComponents(string: webRedirectBaseURLString)
        components?.queryItems = [
            .init(name: "request_id", value: requestId.uuidString),
            .init(name: "tx_hash", value: expectedTxHash)
        ]
        MockAuthenticationSession.setCallbackURL(components!.url!)

        // When:
        let requestAccountMethod = SignAndSendSolanaTransactionMethod(
            id: requestId,
            blockchain: .solana,
            from: "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv",
            message: "testMessage") { result in
                switch result {
                    case let .success(receivedAddress):
                        txHash = receivedAddress
                    case let .failure(error):
                        XCTFail(error.localizedDescription)
                }
            }
        BloctoSDK.shared.send(method: requestAccountMethod)

        // Then:
        XCTAssert(txHash == expectedTxHash, "txHash should be \(expectedTxHash) rather then \(txHash!)")
    }

}
