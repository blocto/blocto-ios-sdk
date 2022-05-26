//
//  EVMBaseSignType.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/5/5.
//

import Foundation

public enum EVMBaseSignType: String {
    case sign
    case personalSign = "personal_sign"
    case typedSignV3 = "typed_sign_v3"
    case typedSignV4 = "typed_sign_v4"
    case typedSign = "typed_sign" // for now, it's same as default v4
}

extension EVMBaseSignType: CaseIterable {}
