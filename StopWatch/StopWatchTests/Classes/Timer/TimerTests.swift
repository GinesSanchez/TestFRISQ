//
//  TimerTests.swift
//  StopWatchTests
//
//  Created by Gines Sanchez Merono on 2020-05-29.
//  Copyright © 2020 Ginés Sanchez. All rights reserved.
//

import XCTest
@testable import StopWatch

class TimerTests: XCTestCase {

    var timer: TimerType!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDispatchSourceTimer_HundredthOfASecondDuringTwoSeconds_BlockRunsTwoHundredTimes() {
        var times = 0
        let expectation = XCTestExpectation()

        self.timer = Timer.init(interval: DispatchTimeInterval.nanoseconds(10),
                                leeway: DispatchTimeInterval.nanoseconds(1),
                                queue: DispatchQueue.init(label: "com.stopWatch.timerQueue"),
                                handler: {
            times += 1
            if (times == 200) {
                expectation.fulfill()
                self.timer.cancel()
            }

        })

        self.timer.resume()
        self.wait(for: [expectation], timeout: 2.01)
    }

    func testDispatchSourceTimer_SecondsDuringFiveSeconds_BlockRunFiveTimes() {
        var times = 0
        let expectation = XCTestExpectation()

        self.timer = Timer.init(interval: DispatchTimeInterval.seconds(1),
                                leeway: DispatchTimeInterval.milliseconds(1),
                                queue: DispatchQueue.init(label: "com.stopWatch.timerQueue"),
                                handler: {
            times += 1
            if (times == 5) {
                expectation.fulfill()
                self.timer.cancel()
            }

        })

        self.timer.resume()
        self.wait(for: [expectation], timeout: 5.01)
    }
}
