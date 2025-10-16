//
//  MockRepository.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 03/10/25.z
//
import Foundation
@testable import SuggestionEngine

class MockActivityRepository: ActivityRepositoryProtocol {
    typealias ActivityType = MockData.MockActivity
    
    var activities: [MockData.MockActivity] = []

    func catalog() -> [MockData.MockActivity] {
        return activities
    }
}
