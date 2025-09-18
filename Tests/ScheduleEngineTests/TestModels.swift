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

struct TestActivity: SchedulableActivity {
    typealias GoalType = TestGoal
    var id: UUID = UUID()
    var name: String
    var minDuration: Int
    var maxDuration: Int
    var goals: Set<TestGoal>
}

struct TestSlot: ScheduleSlot {
    var id: UUID = UUID()
    var range: TimeRange
}
