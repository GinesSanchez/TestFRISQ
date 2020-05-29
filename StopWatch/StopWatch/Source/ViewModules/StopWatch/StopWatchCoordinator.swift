//
//  StopWatchCoordinator.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import UIKit

protocol StopWatchCoordinatorType: Coordinating { }

final class StopWatchCoordinator: StopWatchCoordinatorType {
    let navigationController: UINavigationController
    let viewModuleFactory: ViewModuleFactoryType

    private var stopWatchViewController: StopWatchViewController?

    init(navigationController: UINavigationController, viewModuleFactory: ViewModuleFactoryType) {
        self.navigationController = navigationController
        self.viewModuleFactory = viewModuleFactory
    }

    func start() {
        stopWatchViewController = viewModuleFactory.createStopWatchViewModule()
        navigationController.pushViewController(stopWatchViewController!, animated: true)
    }

    func stop() {
        navigationController.popViewController(animated: true)
        stopWatchViewController = nil
    }
}
