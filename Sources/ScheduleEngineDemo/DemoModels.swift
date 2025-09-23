//
//  DemoGoal.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 18/09/25.
//


import Foundation
import ScheduleEngine

// MARK: - Tipos demo (conformam aos protocolos do engine)

enum DemoGoal: Hashable {
  case loseWeight, gainWeight, quitSedentarism
}

struct DemoActivity: SchedulableActivity {
  typealias Goal = DemoGoal
  var goals: Set<DemoGoal>
  var id = UUID()
  var name: String
  var minDuration: Int
  var maxDuration: Int
}

struct DemoSlot: ScheduleSlot {
  var id: UUID = UUID()
  var range: TimeRange
}
