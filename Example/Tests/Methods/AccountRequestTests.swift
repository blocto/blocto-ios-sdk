//
//  SignAndSendTransactionTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/4/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import BloctoSDK

class AccountRequestTests: XCTestCase {

    var mockUIApplication: MockUIApplication!

    override func setUp() {
        super.setUp()
        mockUIApplication = MockUIApplication()
    }

    func testOpenNativeAppWhenInstalled() {
        // Given:
        let requestId = UUID()
        var address: String?
        let expectedAddress: String = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        if #available(iOS 13.0, *) {
            BloctoSDK.shared.initialize(
                with: appId,
                window: UIWindow(),
                logging: false,
                testnet: true,
                urlOpening: mockUIApplication)
        } else {
            BloctoSDK.shared.initialize(
                with: appId,
                logging: false,
                testnet: true,
                urlOpening: mockUIApplication)
        }

        mockUIApplication.setup(openedOrder: [true])

        // When:
        let requestAccountMethod = RequestAccountMethod(
            id: requestId,
            blockchain: Blockchain.solana) { result in
                switch result {
                case let .success(receivedAddress):
                    address = receivedAddress
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        BloctoSDK.shared.send(method: requestAccountMethod)

        let userActivity = NSUserActivity(activityType: "NSUserActivityTypeBrowsingWeb")
        userActivity.webpageURL = URL(string: "\(appUniversalLinkBaseURLString)blocto?request_id=\(requestId)&address=\(expectedAddress)")

        BloctoSDK.shared.continue(userActivity)

        // Then:
        XCTAssert(address == expectedAddress, "address should be \(expectedAddress) rather then \(address!)")

    }

    func testOpenNativeAppWhenInstalledCustomScheme() {
        // Given:
        let requestId = UUID()
        var address: String?
        let expectedAddress: String = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        if #available(iOS 13.0, *) {
            BloctoSDK.shared.initialize(
                with: appId,
                window: UIWindow(),
                logging: false,
                testnet: true,
                urlOpening: mockUIApplication)
        } else {
            BloctoSDK.shared.initialize(
                with: appId,
                logging: false,
                testnet: true,
                urlOpening: mockUIApplication)
        }

        mockUIApplication.setup(openedOrder: [true])

        // When:
        let requestAccountMethod = RequestAccountMethod(
            id: requestId,
            blockchain: Blockchain.solana) { result in
                switch result {
                case let .success(receivedAddress):
                    address = receivedAddress
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        BloctoSDK.shared.send(method: requestAccountMethod)

        var components = URLComponents(string: appCustomSchemeBaseURLString)
        components?.queryItems = [
            .init(name: "request_id", value: requestId.uuidString),
            .init(name: "address", value: expectedAddress)
        ]
        BloctoSDK.shared.application(
            UIApplication.shared,
            open: components!.url!,
            options: [:])

        // Then:
        XCTAssert(address == expectedAddress, "address should be \(expectedAddress) rather then \(address!)")

    }

    func testOpenWebSDK() {
        // Given:
        let requestId = UUID()
        var address: String?
        let expectedAddress: String = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        if #available(iOS 13.0, *) {
            BloctoSDK.shared.initialize(
                with: appId,
                window: UIWindow(),
                logging: false,
                testnet: true,
                urlOpening: mockUIApplication,
                sessioningType: MockAuthenticationSession.self)
        } else {
            BloctoSDK.shared.initialize(
                with: appId,
                logging: false,
                testnet: true,
                urlOpening: mockUIApplication,
                sessioningType: MockAuthenticationSession.self)
        }

        mockUIApplication.setup(openedOrder: [false])

        var components = URLComponents(string: webRedirectBaseURLString)
        components?.queryItems = [
            .init(name: "address", value: expectedAddress),
            .init(name: "request_id", value: requestId.uuidString)
        ]
        MockAuthenticationSession.setCallbackURL(components!.url!)

        // When:
        let requestAccountMethod = RequestAccountMethod(
            id: requestId,
            blockchain: Blockchain.solana) { result in
                switch result {
                case let .success(receivedAddress):
                    address = receivedAddress
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        BloctoSDK.shared.send(method: requestAccountMethod)

        // Then:
        XCTAssert(address == expectedAddress, "address should be \(expectedAddress) rather then \(address!)")
    }

}
