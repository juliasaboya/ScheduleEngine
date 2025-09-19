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

private func dumpSchedule(
    _ schedule: [Date: [PlannedActivity]],
    slotsById: [UUID: TimeRange],
    timeZone: TimeZone = TimeZone(identifier: "America/Fortaleza")!,
    locale: Locale = Locale(identifier: "pt_BR")
) {
    var cal = Calendar(identifier: .gregorian); cal.timeZone = timeZone

    let dayFmt = DateFormatter()
    dayFmt.locale = locale
    dayFmt.timeZone = timeZone
    // Vamos montar manualmente "Segunda 27/08/2025"
    dayFmt.dateFormat = "dd/MM/yyyy"

    let timeFmt = DateFormatter()
    timeFmt.locale = locale
    timeFmt.timeZone = timeZone
    timeFmt.dateFormat = "HH:mm"

    func shortWeekdayName(_ date: Date) -> String {
        let w = cal.component(.weekday, from: date) // 1=Dom ... 7=Sáb
        // Nomes curtos:
        switch w {
        case 1: return "Domingo"
        case 2: return "Segunda"
        case 3: return "Terça"
        case 4: return "Quarta"
        case 5: return "Quinta"
        case 6: return "Sexta"
        case 7: return "Sábado"
        default: return "Dia"
        }
    }

    for day in schedule.keys.sorted() {
        let label = "\(shortWeekdayName(day))  \(dayFmt.string(from: day))"
        print(label)
        for p in schedule[day] ?? [] {
            guard let slot = slotsById[p.slotId] else { continue }
            let start = slot.start
            let plannedEnd = min(start.addingTimeInterval(TimeInterval(p.duration * 60)), slot.end)
            print("  - \(p.activityName) \(timeFmt.string(from: start)) - \(timeFmt.string(from: plannedEnd))")
        }
        // linha em branco entre dias
        print("")
    }
}
