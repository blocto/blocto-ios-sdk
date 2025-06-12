//
//  URLOpening.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/21.
//

import UIKit

public protocol URLOpening {
    @MainActor
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any]
    ) async -> Bool
    
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    )
}