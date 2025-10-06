//
//  MockData.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 01/10/25.
//
import Foundation
@testable import SuggestionEngine

struct MockData {
    
    struct MockActivity: ActivityProtocol, Equatable, Sendable {
        let id: UUID
        let name: String // Propriedade extra para facilitar os asserts
        let goals: [Goal]
        let intensity: Intensity
        let locations: [Location]
        let minTime: Int
        let maxTime: Int
    }
    
    struct MockUser: UserProtocol, Sendable {
        var availableTime: Int
        var goals: [Goal]
        var intensity: Intensity
        var locations: [Location]
        var activitiesIDs: [UUID]
    }
    
    static let ballet = MockActivity(id: UUID(), name: "Ballet", goals: [.IncreaseFlexibilityAndMobility, .gainMuscle], intensity: .medium, locations: [.gym], minTime: 20, maxTime: 60)
    static let bodybuilding = MockActivity(id: UUID(), name: "Musculação", goals: [.gainMuscle], intensity: .high, locations: [.gym], minTime: 45, maxTime: 90)
    static let running = MockActivity(id: UUID(), name: "Corrida", goals: [.improveFitness, .loseWeight], intensity: .high, locations: [.outdoor], minTime: 15, maxTime: 45)
    
    static let allActivities = [ballet, bodybuilding, running]
}
