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
enum DemoLocationType: Hashable {
    case home, gym, outside
}

struct DemoActivity: SchedulableActivity {
    typealias Goal = DemoGoal
    typealias LocationType = DemoLocationType
    var goals: Set<DemoGoal>
    var locations: Set<LocationType>
    var id = UUID()
    var name: String
    var minDuration: Int
    var maxDuration: Int
}

struct DemoSlot: ScheduleSlot {
    var id: UUID = UUID()
    var range: TimeRange
}
