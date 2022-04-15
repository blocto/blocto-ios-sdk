//
//  XCTAssertArrayElementsEqual.swift
//  BloctoSDK_Tests
//
//  Created by Andrew Wang on 2022/4/9.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

public func XCTAssertArrayElementsEqual<T>(
    _ expression1: @autoclosure () throws -> [T],
    _ expression2: @autoclosure () throws -> [T],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) where T: Equatable {
    do {
        let array1 = try expression1()
        let array2 = try expression2()
        array1.forEach { value in
            if !array2.contains(value) {
                XCTFail("array2 not contain value: \(value)", file: file, line: line)
            }
        }
        XCTAssertEqual(array1.count, array2.count)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
    }
}
