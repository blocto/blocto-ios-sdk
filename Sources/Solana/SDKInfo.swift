//
//  SDKInfo.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/26.
//

import Foundation

enum SDKInfo {

    static var version: String {
        #if COCOAPODS
        return Bundle.resouceBundle?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        #else
        return "0.6.5"
        #endif
    }

}
