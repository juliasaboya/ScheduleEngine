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
  typealias GoalType = DemoGoal
  var id: UUID = UUID()
  var name: String
  var minDuration: Int
  var maxDuration: Int
  var goals: Set<DemoGoal>
}

struct DemoSlot: ScheduleSlot {
  var id: UUID = UUID()
  var range: TimeRange
}