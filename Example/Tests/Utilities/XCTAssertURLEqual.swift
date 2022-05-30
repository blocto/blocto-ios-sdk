//
//  XCTAssertURLEqual.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/5/16.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

public func XCTAssertURLEqual(
    _ expression1: @autoclosure () throws -> URL?,
    _ expression2: @autoclosure () throws -> URL?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    do {
        guard let url1 = try expression1(),
              let urlComponents1 = URLComponents(url: url1, resolvingAgainstBaseURL: false) else {
                  XCTFail("urlComponents1 not found.", file: file, line: line)
                  return
              }
        guard let url2 = try expression2(),
              let urlComponents2 = URLComponents(url: url2, resolvingAgainstBaseURL: false) else {
                  XCTFail("urlComponents2 not found.", file: file, line: line)
                  return
              }

        XCTAssertEqual(urlComponents1.scheme, urlComponents2.scheme)
        XCTAssertEqual(urlComponents1.host, urlComponents2.host)
        XCTAssertEqual(urlComponents1.path, urlComponents2.path)

        guard let queryItems1 = urlComponents1.queryItems,
              let queryItems2 = urlComponents2.queryItems else {
                  XCTFail("queryItems1 is \(String(describing: urlComponents1.queryItems)) and queryItems2 is \(String(describing: urlComponents2.queryItems)) are not equal.", file: file, line: line)
                  return
              }
        XCTAssertArrayElementsEqual(queryItems1, queryItems2)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
