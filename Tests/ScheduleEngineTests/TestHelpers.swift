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

func weekdayLabel(_ day: Date, calendar: Calendar = .current, locale: Locale = Locale(identifier: "pt_BR")) -> String {
    let fmt = DateFormatter()
    fmt.calendar = calendar
    fmt.locale = locale
    fmt.dateFormat = "EEEE, dd/MM/yyyy"
    let raw = fmt.string(from: day)
    return raw.prefix(1).uppercased() + raw.dropFirst()
}

func timeSignature(_ range: TimeRange, calendar: Calendar = .current) -> String {
    let cs = calendar.dateComponents([.hour, .minute], from: range.start)
    let ce = calendar.dateComponents([.hour, .minute], from: range.end)
    let hs = cs.hour ?? 0, ms = cs.minute ?? 0
    let he = ce.hour ?? 0, me = ce.minute ?? 0
    return String(format: "%02d:%02d–%02d:%02d", hs, ms, he, me)
}
