//
//  URLOpening.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/21.
//

import Foundation
#if canImport(UIKit)
import UIKit

public protocol URLOpening {
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    )
}

// MARK: - UIApplication + URLOpening

extension UIApplication: URLOpening {}
#endif
