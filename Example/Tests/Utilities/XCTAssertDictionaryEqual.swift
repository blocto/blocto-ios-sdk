//
//  XCTAssertDictionaryEqual.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/4/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

public func XCTAssertDictionaryEqual<T>(
    _ expression1: @autoclosure () throws -> [String: T],
    _ expression2: @autoclosure () throws -> [String: T],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) where T: Equatable {
    do {
        let dictionary1 = try expression1()
        let dictionary2 = try expression2()
        dictionary1.forEach { key, value in
            if dictionary2[key] != value {
                XCTFail("first value: \(value) of key: \(key) is not equal to second value: \(String(describing: dictionary2[key]))", file: file, line: line)
            }
        }
        XCTAssertEqual(dictionary1.count, dictionary2.count)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
