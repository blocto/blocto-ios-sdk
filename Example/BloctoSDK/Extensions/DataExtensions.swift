//
//  DataExtensions.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/5/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

extension Data {

    init(ethMessage message: String) {
        if message.starts(with: "0x") {
            self = Data(hexString: message) ?? Data(message.utf8)
        } else {
            self = Data(message.utf8)
        }
    }

}
