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
    
    /// Whether to open universal link when testing.
    /// - Parameter openedOrder: To open or not in order. True stands for simulating open with universal link, false stands for opening with the WebSDK.
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
