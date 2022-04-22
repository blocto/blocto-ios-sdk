//
//  AppConsts.swift
//  BloctoSDK_Example
//
//  Created by Andrew Wang on 2022/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

enum AppConsts {
    
    static var solanaRPCEndpoint: URL {
#if Production
        URL(string: "https://api.mainnet-beta.solana.com")!
#else
        URL(string: "https://api.devnet.solana.com")!
#endif
    }
    
}
