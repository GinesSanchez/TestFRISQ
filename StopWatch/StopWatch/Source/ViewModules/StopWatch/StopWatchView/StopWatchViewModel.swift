//
//  StopWatchViewModel.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import Foundation

enum StopWatchViewModelState {
    case initialized
    case ready
    case running
    case stopped
    case trackingLap
    case resetting
}

enum StopWatchViewModelEvent {
    case initializing
    case viewDidLoad
    case mainButtonTapped
    case secondaryButtonTapped
    case lapTracked
    case timeResetted
}

protocol StopWatchViewModelDelegate: class {
    func viewModel(_ viewModel: StopWatchViewModelType, stateDidChange state: StopWatchViewModelState)
    func viewModel(_ viewModel: StopWatchViewModelType, updateTimer time: String)
    func viewModel(_ viewModel: StopWatchViewModelType, updateTrackedLaps lapsArray: [Lap])
}

protocol StopWatchViewModelType {
    init(delegate: StopWatchViewModelDelegate)
}

final class StopWatchViewModel: StopWatchViewModelType {

    private weak var delegate: StopWatchViewModelDelegate?
    private var timer: Timer?

    private var state: StopWatchViewModelState {
        didSet {
            setNextActionWithState(state)
        }
    }

    private var event: StopWatchViewModelEvent {
        didSet {
            updateStateWith(event: event)
        }
    }

    private var hundredthOfASecond: Int = 0 {
        didSet {
            delegate?.viewModel(self, updateTimer: timeFormatted(hundredthOfASecond: hundredthOfASecond))
        }
    }

    private var lapsArray: [Lap] = [] {
        didSet {
            delegate?.viewModel(self, updateTrackedLaps: lapsArray)
        }
    }

    init(delegate: StopWatchViewModelDelegate) {
        self.delegate = delegate
        self.event = .initializing
        self.state = .initialized
    }

    //TODO: Add deinit
}

// MARK: - StopWatchViewControllerDelegate
extension StopWatchViewModel: StopWatchViewControllerDelegate {

    func viewDidLoad() {
        event = .viewDidLoad
    }

    func mainButtonTapped() {
        event = .mainButtonTapped
    }

    func secondaryButtonTapped() {
        event = .secondaryButtonTapped
    }
}

// MARK: - State Machine
private extension StopWatchViewModel {
    func updateStateWith(event: StopWatchViewModelEvent) {
        switch event {
        case .initializing:
            state = .initialized
        case .viewDidLoad:
            if state == .initialized {
                state = .ready
                return
            }
        case .mainButtonTapped:
            if state == .ready {
                state = .running
                return
            }
            if state == .running {
                state = .stopped
                return
            }
            if state == .stopped {
                state = .running
                return
            }
        case .secondaryButtonTapped:
             if state == .running {
                state = .trackingLap
                return
             }
             if state == .stopped {
                state = .resetting
                return
             }
        case .lapTracked:
            if state == .trackingLap {
                state = .running
                return
            }
        case .timeResetted:
            if state == .resetting {
                state = .stopped
                return
            }
            break
        }
    }

    func setNextActionWithState(_ state: StopWatchViewModelState) {
        switch state {
        case .initialized:
                break
        case .ready:
            //TODO: Add move to background notifications
            hundredthOfASecond = 0

        case .running:
            timer = Timer(interval: DispatchTimeInterval.milliseconds(10),
                          leeway: DispatchTimeInterval.milliseconds(1),
                          queue: DispatchQueue.init(label: "com.stopWatch.timerQueue"),
                          handler: { [weak self] in

                self?.hundredthOfASecond += 1
            })
            timer?.resume()

        case .stopped:
            timer?.cancel()
        case .trackingLap:
            let trackedLap = Lap(title: "Lap \(lapsArray.count + 1)",
                                time: timeFormatted(hundredthOfASecond: hundredthOfASecond))
            lapsArray.append(trackedLap)
            event = .lapTracked
            break
        case .resetting:
            hundredthOfASecond = 0
            lapsArray = []
            event = .timeResetted
            break
        }

        delegate?.viewModel(self, stateDidChange: state)
    }
}

// MARK: - Helpers
private extension StopWatchViewModel {
    //TODO: Move to an extension
    func timeFormatted(hundredthOfASecond totalHundredthOfASecond: Int) -> String {
        let hundredthOfASecond = totalHundredthOfASecond % 100
        let totalSeconds = totalHundredthOfASecond / 100
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600

        if (hours > 0) {
            return String(format: "%02d:%02d:%02d,%02d", hours, minutes, seconds, hundredthOfASecond)
        } else {
            return String(format: "%02d:%02d,%02d",minutes, seconds, hundredthOfASecond)
        }
    }
}

private extension StopWatchViewModel {

}
