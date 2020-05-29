//
//  ViewModuleFactory.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import Foundation

protocol ViewModuleFactoryType {
    func createStopWatchViewModule() -> StopWatchViewController
}

final class ViewModuleFactory: ViewModuleFactoryType {
    func createStopWatchViewModule() -> StopWatchViewController {
        let viewController: StopWatchViewController = StopWatchViewController.init(nibName: "StopWatchViewController", bundle: nil)
        let viewModel: StopWatchViewModel = StopWatchViewModel.init(delegate: viewController)
        viewController.viewModel = viewModel
        return viewController
    }
}
