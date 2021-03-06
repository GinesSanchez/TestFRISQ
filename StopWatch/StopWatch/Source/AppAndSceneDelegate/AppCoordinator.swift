//
//  AppCoordinator.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import UIKit

protocol AppCoordinatorType: Coordinating { }

final class AppCoordinator: AppCoordinatorType {

    let navigationController: UINavigationController
    let viewModuleFactory: ViewModuleFactoryType

    private var stopWatchCoordinator: StopWatchCoordinatorType?

    init(navigationController: UINavigationController, viewModuleFactory: ViewModuleFactoryType) {
        self.navigationController = navigationController
        self.viewModuleFactory = viewModuleFactory
    }

    func start() {
        self.stopWatchCoordinator = StopWatchCoordinator.init(navigationController: self.navigationController,
                                                              viewModuleFactory: self.viewModuleFactory)
        self.stopWatchCoordinator?.start()
    }

    func stop() {
        self.stopWatchCoordinator?.stop()
    }
}
