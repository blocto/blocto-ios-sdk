//
//  XCTAssertURLComponentsEqual.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/5/16.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

public func XCTAssertURLComponentsEqual(
    _ expression1: @autoclosure () throws -> URLComponents,
    _ expression2: @autoclosure () throws -> URLComponents,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    do {
        let urlComponents1 = try expression1()
        let urlComponents2 = try expression2()

        XCTAssertEqual(urlComponents1.scheme, urlComponents2.scheme)
        XCTAssertEqual(urlComponents1.host, urlComponents2.host)
        XCTAssertEqual(urlComponents1.path, urlComponents2.path)
        XCTAssertArrayElementsEqual(urlComponents1.queryItems ?? [], urlComponents2.queryItems ?? [])
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
