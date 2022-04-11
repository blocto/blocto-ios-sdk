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

    private let appUniversalLinkBaseURLString: String = "https://c161-61-216-44-25.ngrok.io/"
    private var mockUIApplication: MockUIApplication!

    override func setUp() {
        super.setUp()
        mockUIApplication = MockUIApplication()
    }

    override func tearDownWithError() throws {
        mockUIApplication = nil
    }

    func testSendBack() throws {
        // Given:
        let requestId = UUID().uuidString
        let address = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        var expectedOpened: Bool = false

        mockUIApplication.setup(opened: true)

        // When:
        MethodCallbackHelper.sendBack(
            urlOpening: mockUIApplication,
            requestId: requestId,
            methodContentType: .requestAccount(address: address),
            baseURLString: appUniversalLinkBaseURLString) { opened in
                expectedOpened = opened
            }

        // Then:
        XCTAssertEqual(expectedOpened, true)
    }

    func testRequestAccountQueryItems() throws {
        // Given:
        let address = "2oz91K9pKf2sYr4oRtQvxBcxxo8gniZvXyNoMTQYhoqv"
        let callbackMethodContentType: CallbackMethodContentType = .requestAccount(address: address)
        let expectResult: [URLQueryItem] = [.init(name: .address, value: address)]

        // When:
        let result = MethodCallbackHelper.queryItems(from: callbackMethodContentType)

        // Then:
        XCTAssertEqual(result, expectResult)
    }

}
