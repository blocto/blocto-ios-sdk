//
//  GeneralMethodContentType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/16.
//

import Foundation

public enum GeneralMethodContentType {
    case solana(SolanaMethodContentType)
    case evmBase(EVMBaseMethodContentType)
    case flow(FlowMethodContentType)
}
