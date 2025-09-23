//
//  DemoHelpers.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 18/09/25.
//

import Foundation
import ScheduleEngine

// MARK: - Helpers de data/tempo (timezone Fortaleza)

func fortalezaCalendar() -> Calendar {
  var cal = Calendar(identifier: .gregorian)
  cal.timeZone = TimeZone(identifier: "America/Fortaleza")!
  return cal
}

func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ min: Int) -> Date {
  var comps = DateComponents()
  comps.year = y; comps.month = m; comps.day = d
  comps.hour = h; comps.minute = min; comps.second = 0
  return fortalezaCalendar().date(from: comps)!
}

func slot(_ y: Int, _ m: Int, _ d: Int, _ sh: Int, _ sm: Int, _ eh: Int, _ em: Int) -> DemoSlot {
  DemoSlot(range: TimeRange(start: date(y, m, d, sh, sm), end: date(y, m, d, eh, em)))
}

func hhmm(_ date: Date) -> String {
  let f = DateFormatter()
  f.locale = Locale(identifier: "pt_BR")
  f.timeZone = TimeZone(identifier: "America/Fortaleza")
  f.dateFormat = "HH:mm"
  return f.string(from: date)
}

func fmtRange(_ r: TimeRange) -> String { "\(hhmm(r.start)) às \(hhmm(r.end))" }
