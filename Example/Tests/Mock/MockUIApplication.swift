//
//  MockUIApplication.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/3/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import BloctoSDK

class MockUIApplication: URLOpening {

    var url: URL?
    var lastOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?
    private var openedOrder: [Bool] = []
    private var callback: ((_ url: URL?) -> Void)?

    func setup(openedOrder: [Bool]) {
        self.openedOrder = openedOrder
    }

    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    ) {
        self.url = url
        lastOptions = options
        let first = openedOrder.removeFirst()
        completion?(first)
    }

}
