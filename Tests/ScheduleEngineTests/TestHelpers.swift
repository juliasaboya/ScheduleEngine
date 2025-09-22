//
//  TestHelpers.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 17/09/25.
//

import Foundation
@testable import ScheduleEngine

// Fuso do TEMPLATE (origem) — UTC
let TEMPLATE_TZ = TimeZone(secondsFromGMT: 0)!

func makeDate(_ day: Date, hour: Int, minute: Int) -> Date {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TEMPLATE_TZ // mantém UTC para o template
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

// (Opcional) criar slots diretamente num calendário local do teste, se precisar:
func makeLocalSlot(_ day: Date, startH: Int, startM: Int, endH: Int, endM: Int, calendar: Calendar) -> TestSlot {
    let start = calendar.date(bySettingHour: startH, minute: startM, second: 0, of: day)!
    let end   = calendar.date(bySettingHour: endH,   minute: endM,   second: 0, of: day)!
    return TestSlot(range: TimeRange(start: start, end: end))
}

// Formatadores (ok manter)
func fmtDay(_ d: Date, cal: Calendar) -> String {
    let df = DateFormatter()
    df.calendar = cal
    df.locale = Locale(identifier: "pt_BR")
    df.timeZone = cal.timeZone
    df.dateFormat = "EEEE dd/MM/yyyy"
    return df.string(from: d)
}

func fmtActivity(_ p: PlannedActivity, slotsById: [UUID: TimeRange], cal: Calendar) -> String {
    guard let r = slotsById[p.slotId] else {
        return "  - \(p.activityName) [slot desconhecido] (\(p.duration)min)"
    }
    let tf = DateFormatter()
    tf.calendar = cal
    tf.locale = Locale(identifier: "pt_BR")
    tf.timeZone = cal.timeZone
    tf.dateFormat = "HH:mm"
    return "  - \(p.activityName) \(tf.string(from: r.start))-\(tf.string(from: r.end)) (\(p.duration)min)"
}
