//
//  URLOpener.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2025/1/16.
//

import UIKit

// TODO(hellohuanlin): This wrapper is a workaround for iOS 18 Beta 3 where completionHandler is annotated with @MainActor @Sendable, resulting in compile error when conforming UIApplication to Launcher. We should try again in newer betas.
// https://github.com/flutter/packages/pull/7100/files
final public class URLOpener: URLOpening {
    
    public init() {}

    @MainActor
    public func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey : Any]
    ) async -> Bool {
        await UIApplication.shared.open(
            url,
            options: options)
    }

    public func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    ) {
        UIApplication.shared.open(
            url,
            options: options,
            completionHandler: completion)
    }
}
