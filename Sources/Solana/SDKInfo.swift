//
//  SDKInfo.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/26.
//

import Foundation

enum SDKInfo {

    static var version: String {
        Bundle.module?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

}
