//
//  AppDelegate.swift
//  BloctoSDK
//
//  Created by scottphc on 01/12/2022.
//  Copyright (c) 2022 scottphc. All rights reserved.
//

import UIKit
import BloctoSDK
import Firebase

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private let bloctoSDKAppId: String = "64776cec-5953-4a58-8025-772f55a3917b"
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        let window = UIWindow()
        self.window = window
        let viewController = ViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        if #available(iOS 13.0, *) {
            BloctoSDK.shared.initialize(
                with: bloctoSDKAppId,
                window: window,
                logging: true,
                testnet: true)
        } else {
            BloctoSDK.shared.initialize(
                with: bloctoSDKAppId,
                logging: true,
                testnet: true)
        }
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        BloctoSDK.shared.application(
            app,
            open: url,
            options: options)
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
