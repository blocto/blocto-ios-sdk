//
//  Consts.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/4/18.
//

import Foundation

enum AppInfo {

    static var applicationBundle: Bundle {
        let bundle = Bundle.main
        switch bundle.bundleURL.pathExtension {
            case "app":
                return bundle
            case "appex":
                // .../Client.app/PlugIns/SendTo.appex
                return Bundle(url: bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent())!
            default:
                fatalError("Unable to get application Bundle (Bundle.main.bundlePath=\(bundle.bundlePath))")
        }
    }

    static var appVersion: String {
        return applicationBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

}

enum AppConstants {

    static var apiBaseURL: URL {
#if Production
        URL(string: "https://api.blocto.app")!
#else
        URL(string: "https://api-staging.blocto.app")!
#endif
    }

    static var walletProgramIds: String {
#if Production
        "JBn9VwAiqpizWieotzn6FjEXrBu4fDe2XFjiFqZwp8Am"
#else
        "Ckv4czD7qPmQvy2duKEa45WRp3ybD2XuaJzQAWrhAour"
#endif
    }

    static var solanaRPCEndpoint: URL {
#if Production
        URL(string: "https://api.mainnet-beta.solana.com")!
#else
        URL(string: "https://api.devnet.solana.com")!
#endif
    }

}
