//
//  Repository.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 17/09/25.
//

// contém os protocolos necessários para realizar as operações com entidades da aplicação

import Foundation

public struct ScheduleEngine {
  public init() {}
}

public protocol SchedulableActivity {
  associatedtype GoalType: Hashable
  var id: UUID { get }
  var name: String { get }
  var minDuration: Int { get }
  var maxDuration: Int { get }
  var goals: Set<GoalType> { get }
}

public protocol ScheduleSlot {
    var id: UUID { get }
    var range: TimeRange { get }
}

public protocol UserGoalMarker {}

public struct TimeRange: Equatable, Codable {
    public let start: Date
    public let end: Date
    public init(start: Date, end: Date) { self.start = start; self.end = end }
}

public struct PlannedActivity: Identifiable, Equatable, Codable {
    public let id: UUID
    public let activityName: String
    public let duration: Int
    public let slotId: UUID
    public init(id: UUID = UUID(), activityName: String, duration: Int, slotId: UUID) {
        self.id = id
        self.activityName = activityName
        self.duration = duration
        self.slotId = slotId
    }
}


public struct EngineOptions: Sendable {
  public var dailyMinimumMinutes: Int
  public var avoidConsecutiveRepeat: Bool
  public init(dailyMinimumMinutes: Int = 50, avoidConsecutiveRepeat: Bool = true) {
    self.dailyMinimumMinutes = dailyMinimumMinutes
    self.avoidConsecutiveRepeat = avoidConsecutiveRepeat
  }
}

public enum ScheduleEngineError: Error {
    case noSlots
    case noActivities
}

public enum Intensity: String, Codable, Sendable { case low, medium, high }


