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
            routingInfo: RoutingInfo(
                appId: appId,
                requestId: requestId,
                methodContentType: .requestAccount(address: address),
                baseURLString: appUniversalLinkBaseURLString)) { opened in
                    receivingOpened = opened
                }

        // Then:
        XCTAssertArrayElementsEqual(
            URLComponents(
                url: mockUIApplication.url!,
                resolvingAgainstBaseURL: false)!.queryItems!,
            URLComponents(
                url: URL(string: "\(appUniversalLinkBaseURLString)blocto?request_id=\(requestId)&address=\(address)")!,
                resolvingAgainstBaseURL: false)!.queryItems!)
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
            routingInfo: RoutingInfo(
                appId: appId,
                requestId: requestId,
                methodContentType: .requestAccount(address: address),
                baseURLString: appUniversalLinkBaseURLString)) { opened in
                    receivingOpened = opened
                }

        // Then:
        XCTAssertArrayElementsEqual(
            URLComponents(
                url: mockUIApplication.url!,
                resolvingAgainstBaseURL: false)!.queryItems!,
            URLComponents(
                url: URL(string: "\(appCustomSchemeBaseURLString)?request_id=\(requestId)&address=\(address)")!,
                resolvingAgainstBaseURL: false)!.queryItems!)

        XCTAssertEqual(receivingOpened!, true)
    }

    func testRequestAccountQueryItems() throws {
        // Given:
        let address = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        let callbackMethodContentType: CallbackMethodContentType = .requestAccount(address: address)
        let expectResult: [URLQueryItem] = [
            .init(name: .address, value: address)
        ]

        // When:
        let result = MethodCallbackHelper.queryItems(from: callbackMethodContentType)

        // Then:
        XCTAssertArrayElementsEqual(result, expectResult)
    }

}
