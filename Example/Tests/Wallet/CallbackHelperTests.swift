//
//  CallbackHelperTests.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/4/11.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import BloctoSDK

class CallbackHelperTests: XCTestCase {

    private var mockUIApplication: MockUIApplication!

    override func setUp() {
        super.setUp()
        mockUIApplication = MockUIApplication()
    }

    override func tearDownWithError() throws {
        mockUIApplication = nil
    }

    func testSendBackUniversalLinksSuccess() throws {
        // Given:
        let requestId = UUID().uuidString
        let address = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        let expectedOpenedOrder: [Bool] = [true]
        var receivingOpened: Bool?

        mockUIApplication.setup(openedOrder: expectedOpenedOrder)

        // When:
        MethodCallbackHelper.sendBack(
            urlOpening: mockUIApplication,
            appId: appId,
            methodContentType: .requestAccount(
                requestId: requestId,
                address: address),
            baseURLString: appUniversalLinkBaseURLString) { opened in
                receivingOpened = opened
            }

        // Then:
        XCTAssertEqual(mockUIApplication.url, URL(string: "\(appUniversalLinkBaseURLString)blocto?request_id=\(requestId)&address=\(address)")!)
        // swiftlint:disable force_cast
        XCTAssertEqual(mockUIApplication.lastOptions as! [UIApplication.OpenExternalURLOptionsKey: Bool], [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true])
        XCTAssertEqual(receivingOpened, true)
    }

    func testSendBackUniversalLinksFailed() throws {
        // Given:
        let requestId = UUID().uuidString
        let address = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        let openedOrder: [Bool] = [false, true]
        var receivingOpened: Bool?

        mockUIApplication.setup(openedOrder: openedOrder)

        // When:
        MethodCallbackHelper.sendBack(
            urlOpening: mockUIApplication,
            appId: appId,
            methodContentType: .requestAccount(
                requestId: requestId,
                address: address),
            baseURLString: appUniversalLinkBaseURLString) { opened in
                receivingOpened = opened
            }

        // Then:
        XCTAssertEqual(mockUIApplication.url, URL(string: "\(appCustomSchemeBaseURLString)?request_id=\(requestId)&address=\(address)")!)
        XCTAssertEqual(receivingOpened!, true)
    }

    func testRequestAccountQueryItems() throws {
        // Given:
        let requestId = UUID().uuidString
        let address = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        let callbackMethodContentType: CallbackMethodContentType = .requestAccount(
            requestId: requestId,
            address: address)
        let expectResult: [URLQueryItem] = [
            .init(name: .requestId, value: requestId),
            .init(name: .address, value: address)
        ]

        // When:
        let result = MethodCallbackHelper.queryItems(from: callbackMethodContentType)

        // Then:
        XCTAssertArrayElementsEqual(result, expectResult)
    }

}
