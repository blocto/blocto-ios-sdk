//
//  AppDelegate.swift
//  BloctoSDK
//
//  Created by scottphc on 01/12/2022.
//  Copyright (c) 2022 scottphc. All rights reserved.
//

import UIKit
import BloctoSDK

var bloctoEnvironment: BloctoEnvironment = .dev

var bloctoSDKAppId: String {
    switch bloctoEnvironment {
    case .prod:
        return "0896e44c-20fd-443b-b664-d305b52fe8e8"
    case .dev:
        return "0896e44c-20fd-443b-b664-d305b52fe8e8"
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
            environment: .dev
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
