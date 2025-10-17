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
        let id: String
        let name: String // Propriedade extra para facilitar os asserts
        let goals: [Goal]
        let intensity: Intensity
        let locations: [LocationType]
        let minTime: Int
        let maxTime: Int
    }
    
    struct MockUser: UserProtocol, Sendable {
        var availableTime: Int
        var goals: [Goal]
        var intensity: Intensity
        var locations: [LocationType]
        var activitiesIDs: [String]
    }
    
    static let ballet = MockActivity(id: "DAN-BAL-001", name: "Ballet", goals: [.flexibility, .gainMuscle], intensity: .medium, locations: [.gym], minTime: 20, maxTime: 60)
    static let bodybuilding = MockActivity(id: "FOR-MUS-001", name: "Musculação", goals: [.gainMuscle], intensity: .high, locations: [.gym], minTime: 45, maxTime: 90)
    static let running = MockActivity(id: "AER-COR-001", name: "Corrida", goals: [.improveCondition, .loseWeight], intensity: .high, locations: [.outdoor], minTime: 15, maxTime: 45)
    
    static let allActivities = [ballet, bodybuilding, running]
}
