//
//  MockUIApplication.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/3/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import BloctoSDK

class MockUIApplication: URLOpening {

    private var opened: Bool = false

    func setup(opened: Bool) {
        self.opened = opened
    }

    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    ) {
        completion?(opened)
    }

}
