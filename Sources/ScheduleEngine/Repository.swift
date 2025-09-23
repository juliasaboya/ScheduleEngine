//
//  Repository.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 17/09/25.
//

// contém os protocolos necessários para realizar as operações com entidades da aplicação

import Foundation

public protocol SchedulableActivity {
  associatedtype Goal: Hashable
    associatedtype LocationType: Hashable
  var id: UUID { get }
  var name: String { get }
  var minDuration: Int { get }
  var maxDuration: Int { get }
  var goals: Set<Goal> { get }
  var locations: Set<LocationType> { get }
}

public protocol ScheduleSlot {
    var id: UUID { get }
    var range: TimeRange { get }
}

public protocol UserGoalMarker {}

public struct TimeRange: Equatable, Codable {
    public let start: Date
    public let end: Date
    public init(start: Date, end: Date) {
        self.start = start; self.end = end
    }
    public func durationInMinutes() -> Int {
        max(0, Int(end.timeIntervalSince(start) / 60))
    }
}

public struct PlannedActivity: Identifiable, Equatable, Codable {
    public let id: UUID
    public let activityId: UUID
    public let slotId: UUID
    public let plannedMinutes: Int
    public init(id: UUID = UUID(), activityId: UUID, slotId: UUID, plannedMinutes: Int) {
        self.id = id
        self.activityId = activityId
        self.slotId = slotId
        self.plannedMinutes = plannedMinutes
    }
    public func activityName(from namesById: [UUID: String]) -> String {
        namesById[activityId] ?? "<desconhecido>"
    }
}

public struct EngineOptions: Sendable {
  public var dailyMinimumMinutes: Int
  public var dailyMaximumMinutes: Int
  public var avoidConsecutiveRepeat: Bool

  public init(dailyMinimumMinutes: Int, dailyMaximumMinutes: Int, avoidConsecutiveRepeat: Bool = true) {
    self.dailyMinimumMinutes = dailyMinimumMinutes
    self.dailyMaximumMinutes = dailyMaximumMinutes
    self.avoidConsecutiveRepeat = avoidConsecutiveRepeat
  }
}

public enum ScheduleEngineError: Error {
    case noSlots
    case noActivities
    case slotsMinutesNotEnough

}

public enum Intensity: String, Codable, Sendable { case low, medium, high }

public enum ExcludedHandling {
   case auto        // regra: força reposição se daysToPlan == 3; caso contrário, não força
   case reschedule  // sempre força reposição até atingir o total (se houver dias livres)
   case drop        // nunca força reposição (aceita menos dias)
 }


extension Set where Element == AnyHashable {
    init<T: Hashable>(one value: T) {
        self.init([AnyHashable(value)])
    }

    init<S: Sequence>(many source: S) where S.Element: Hashable {
        self.init(source.map(AnyHashable.init))
    }
}

