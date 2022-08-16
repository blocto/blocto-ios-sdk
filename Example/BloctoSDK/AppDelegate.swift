//
//  AppDelegate.swift
//  BloctoSDK
//
//  Created by scottphc on 01/12/2022.
//  Copyright (c) 2022 scottphc. All rights reserved.
//

import UIKit
import BloctoSDK

var isProduction = false

var bloctoSDKAppId: String {
    if isProduction {
        return "9c2d24b6-4358-46fc-b967-e3284805a856"
    } else {
        return "64776cec-5953-4a58-8025-772f55a3917b"
    }
}

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow()
        self.window = window
        let menuViewController = MenuViewController()
        let navigationController = UINavigationController(rootViewController: menuViewController)
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        BloctoSDK.shared.initialize(
            with: bloctoSDKAppId,
            getWindow: { window },
            logging: true,
            testnet: true
        )
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        BloctoSDK.shared.application(
            open: url
        )
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        BloctoSDK.shared.continue(userActivity)
        return true
    }

}
