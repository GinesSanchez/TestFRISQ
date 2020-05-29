//
//  AppDelegate.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoodinator: AppCoordinatorType?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.appCoodinator = AppCoordinator.init(navigationController: UINavigationController(), viewModuleFactory: ViewModuleFactory())

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = self.appCoodinator?.navigationController
        self.appCoodinator?.start()
        window?.makeKeyAndVisible()
        return true
    }

}

