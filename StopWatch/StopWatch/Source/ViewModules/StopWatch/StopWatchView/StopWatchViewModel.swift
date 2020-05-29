//
//  StopWatchViewModel.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import UIKit

let currentTimeInHundredthOfSecondsKey = "currentTimeInHundredthOfSeconds"
let hundredthOfSecondsKey = "hundredthOfSeconds"
let currentStateKey = "currentState"

enum StopWatchViewModelState: String {
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

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
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
            hundredthOfASecond = 0
            lapsArray = []

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(saveStopWatchState),
                                                   name: UIApplication.willResignActiveNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(saveStopWatchState),
                                                   name: UIApplication.willTerminateNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(restoreStopWatchState),
                                                   name: UIApplication.didBecomeActiveNotification,
                                                   object: nil)

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

    @objc func saveStopWatchState(note: NSNotification) {
        //TODO: Save laps

        UserDefaults.standard.set(hundredthOfASecond, forKey: hundredthOfSecondsKey)
        UserDefaults.standard.set(CFAbsoluteTimeGetCurrent() * 100, forKey: currentTimeInHundredthOfSecondsKey)
        UserDefaults.standard.set(state.rawValue, forKey: currentStateKey)
    }

    @objc func restoreStopWatchState(note: NSNotification) {
        //TODO: Restore laps

        guard let previousStateString = UserDefaults.standard.string(forKey: currentStateKey),
                let previousState = StopWatchViewModelState(rawValue: previousStateString) else {
            return
        }

        UserDefaults.standard.removeObject(forKey: currentStateKey)

        switch previousState {
            case .initialized:
                break
            case .ready, .running:
                let previousHundredthOfSecondsInt = UserDefaults.standard.integer(forKey: hundredthOfSecondsKey)
                let previousTimeInHundredthOfSecondsInt = UserDefaults.standard.integer(forKey: currentTimeInHundredthOfSecondsKey)

                let previousTimeInHundredthOfSeconds: CFAbsoluteTime = Double(previousTimeInHundredthOfSecondsInt)
                let currentTimeInHundredthOfSeconds: Double = CFAbsoluteTimeGetCurrent() * 100
                let previousHundredOfSeconds: Double = Double(previousHundredthOfSecondsInt)

                self.hundredthOfASecond = Int(previousHundredOfSeconds + (currentTimeInHundredthOfSeconds - previousTimeInHundredthOfSeconds))
                UserDefaults.standard.removeObject(forKey: hundredthOfSecondsKey)
                UserDefaults.standard.removeObject(forKey: currentTimeInHundredthOfSecondsKey)
            case .stopped:
                let previousHundredthOfSecondsInt = UserDefaults.standard.integer(forKey: hundredthOfSecondsKey)
                self.hundredthOfASecond = previousHundredthOfSecondsInt
                UserDefaults.standard.removeObject(forKey: hundredthOfSecondsKey)
                UserDefaults.standard.removeObject(forKey: currentTimeInHundredthOfSecondsKey)
            case .trackingLap:
                break
            case .resetting:
                break
        }

        self.state = previousState
    }
}


