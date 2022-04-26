//
//  BundleExtension.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/26.
//

import Foundation

extension Bundle {

    static var resouceBundle: Bundle? {
#if SWIFT_PACKAGE
        return Bundle.resouceBundle
#else
        return Bundle(identifier: "org.cocoapods.BloctoSDK")
#endif
    }

}
