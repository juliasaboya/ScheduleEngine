//
//  TestHelpers.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 17/09/25.
//

import Foundation
@testable import ScheduleEngine

func makeDate(_ day: Date, hour: Int, minute: Int) -> Date {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 0)! // evita variações por timezone/DST nos testes
    return cal.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
}

func makeSlot(_ day: Date, startH: Int, startM: Int, endH: Int, endM: Int) -> TestSlot {
    let start = makeDate(day, hour: startH, minute: startM)
    let end = makeDate(day, hour: endH, minute: endM)
    return TestSlot(range: TimeRange(start: start, end: end))
}

func minutes(_ range: TimeRange) -> Int {
    max(0, Int(range.end.timeIntervalSince(range.start) / 60))
}
