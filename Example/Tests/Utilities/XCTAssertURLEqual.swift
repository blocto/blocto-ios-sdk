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
        guard let url1 = try expression1() else {
            XCTFail("url1 not found.", file: file, line: line)
            return
        }
        guard let url1QueryPart = url1.absoluteString.components(separatedBy: "?").last else {
            XCTFail("url1 query part not found.", file: file, line: line)
            return
        }
        guard let url2 = try expression2() else {
            XCTFail("url2 not found.", file: file, line: line)
            return
        }
        guard let url2QueryPart = url2.absoluteString.components(separatedBy: "?").last else {
            XCTFail("url2 query part not found.", file: file, line: line)
            return
        }

        XCTAssertEqual(url1.host, url2.host)
        XCTAssertEqual(url1.scheme, url2.scheme)
        let url1QueryComponents = url1QueryPart.components(separatedBy: "&")
        let url2QueryComponents = url2QueryPart.components(separatedBy: "&")
        XCTAssertArrayElementsEqual(url1QueryComponents, url2QueryComponents)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
