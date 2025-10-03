//
//  Contractes.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 03/10/25.
//

import Foundation

public protocol UserProtocol {
    var availableTime: Int { get }
    var goals: [Goal] { get }
    var intensity: Intensity { get }
    var locations: [Location] { get }
    var activitiesIDs: [UUID] { get }
}

public protocol ActivityProtocol {
    var id: UUID { get }
    var goals: [Goal] { get }
    var intensity: Intensity { get }
    var locations: [Location] { get }
    var minTime: Int { get }
    var maxTime: Int { get }
}

// MARK: - Repository Protocol

public protocol ActivityRepositoryProtocol<ActivityType> {
    associatedtype ActivityType: ActivityProtocol
    func fetchAllActivities() -> [ActivityType]
}

