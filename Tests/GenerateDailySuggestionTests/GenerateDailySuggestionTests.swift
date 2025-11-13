//
//  GenerateDailySuggestionTests.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 01/10/25.
//

import XCTest
@testable import SuggestionEngine

final class SuggestionEngineTests: XCTestCase {
    
    var mockRepository: MockActivityRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockActivityRepository()
        mockRepository.activities = MockData.allActivities
    }
    
    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }
    
    func test_generateSuggestions_whenUserHasLimitedTime_returnsOnlyFittingActivities() {
        // Arrange
        let user = MockData.MockUser(availableTime: 18, goals: [.improveCondition], intensity: .medium, locations: [.outdoor], activitiesIDs: [])
        
        // Act
        let suggestions = SuggestionEngineService.generateDailySuggestions(user: user, options: SetOption(), repository: mockRepository)

        // Assert
        XCTAssertEqual(suggestions.count, 1, "Apenas a corrida (min 15) deveria ser sugerida, Ballet (min 20) e Musculação (min 45) não.")
        XCTAssertEqual(suggestions.first?.activity.name, "Corrida")
    }
    
    func test_generateSuggestions_whenUserHasSpecificActivityIDs_returnsOnlyThoseActivities() {
        // Arrange
        let user = MockData.MockUser(availableTime: 60, goals: [.flexibility], intensity: .low, locations: [.home], activitiesIDs: [MockData.ballet.id])
        
        // Act
        let suggestions = SuggestionEngineService.generateDailySuggestions(user: user, options: SetOption(), repository: mockRepository)
        
        // Assert
        XCTAssertEqual(suggestions.count, 1, "Apenas a atividade preferida do usuário (Yoga) deveria ser considerada.")
        XCTAssertEqual(suggestions.first?.activity.id, MockData.ballet.id)
    }
    
    func test_generateSuggestions_calculatesCorrectSuggestedDuration() {
        // Arrange
        // O usuário tem 30 min, mas a corrida tem um máximo de 45. A sugestão deve ser 30.
        let user1 = MockData.MockUser(availableTime: 30, goals: [.improveCondition], intensity: .medium, locations: [.outdoor], activitiesIDs: [])
        
        // O usuário tem 60 min, mas a corrida tem um máximo de 45. A sugestão deve ser 45.
        let user2 = MockData.MockUser(availableTime: 60, goals: [.improveCondition], intensity: .medium, locations: [.outdoor], activitiesIDs: [])
        
        // Act
        let suggestions1 = SuggestionEngineService.generateDailySuggestions(user: user1, options: SetOption(), repository: mockRepository)
        let suggestions2 = SuggestionEngineService.generateDailySuggestions(user: user2, options: SetOption(), repository: mockRepository)
        
        // Assert
        XCTAssertEqual(suggestions1.first?.suggestedDuration, 30)
        XCTAssertEqual(suggestions2.first?.suggestedDuration, 45, "A duração sugerida deve ser limitada pelo maxTime da atividade.")
    }
    
    func test_generateSuggestions_whenOptionsOverrideUserPrefs_usesOptions() {
        // Arrange
        // Preferência do usuário é .low, mas a opção da UI é .high
        let user = MockData.MockUser(availableTime: 60, goals: [.gainMuscle], intensity: .low, locations: [.gym], activitiesIDs: [])
        let options = SetOption(intensity: .high)
        
        // Act
        let suggestions = SuggestionEngineService.generateDailySuggestions(user: user, options: options, repository: mockRepository)
        
        // Assert
        // A musculação (intensidade .high) deve ter a maior pontuação por causa do override da opção.
        XCTAssertEqual(suggestions.first?.activity.name, "Musculação")
    }
}
