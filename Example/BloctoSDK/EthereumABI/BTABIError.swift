// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public enum BTABIError: LocalizedError {
    case integerOverflow
    case invalidUTF8String
    case invalidNumberOfArguments
    case invalidArgumentType
    case functionSignatureMismatch
    case arrayNotSupported

    public var errorDescription: String {
        switch self {
        case .integerOverflow:
            return "Integer overflow"
        case .invalidUTF8String:
            return "Can't encode string as UTF8"
        case .invalidNumberOfArguments:
            return "Invalid number of arguments"
        case .invalidArgumentType:
            return "Invalid argument type"
        case .functionSignatureMismatch:
            return "Function signature mismatch"
        case .arrayNotSupported:
            return "Array not supported in typed_data_sign_v3."
        }
    }
}
