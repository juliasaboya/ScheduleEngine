//
//  TestModels.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 17/09/25.
//

import Foundation
@testable import ScheduleEngine

enum TestGoal: Hashable {
    case loseWeight, gainWeight, quitSedentarism
}
enum TestLocationType: Hashable {
    case home, gym, outside
}

struct TestActivity: SchedulableActivity {
  typealias Goal = TestGoal
    typealias LocationType = TestLocationType
  var goals: Set<TestGoal>
    var locations: Set<LocationType>
  var id = UUID()
  var name: String
  var minDuration: Int
  var maxDuration: Int
}

struct TestSlot: ScheduleSlot {
    var id: UUID = UUID()
    var range: TimeRange
}
