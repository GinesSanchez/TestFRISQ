//
//  Timer.swift
//  StopWatch
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import Foundation

protocol TimerType {
    init(interval: DispatchTimeInterval, leeway: DispatchTimeInterval, queue: DispatchQueue, handler: @escaping (() -> Void))
    func resume()
    func cancel()
}

final class Timer: TimerType {

    private let timer: DispatchSourceTimer
    private let startedTimeInSeconds: CFAbsoluteTime

    init(interval: DispatchTimeInterval, leeway: DispatchTimeInterval, queue: DispatchQueue, handler: @escaping (() -> Void)) {
        self.startedTimeInSeconds = CFAbsoluteTimeGetCurrent()
        self.timer = DispatchSource.makeTimerSource(queue: queue)
        self.timer.schedule(deadline: DispatchTime.now(), repeating: interval, leeway: leeway)
        self.timer.setEventHandler(handler: handler)
    }

    func resume() {
        self.timer.resume()
    }

    func cancel() {
        self.timer.cancel()
    }
}
