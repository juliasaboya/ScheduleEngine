//
//  GenerateDailySuggestionTests.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 01/10/25.
//

import XCTest
@testable import ScheduleEngine // Importe seu módulo principal

// O MockRepository fica DENTRO da pasta de testes
class MockActivityRepository: ActivityRepositoryProtocol {
    var activitiesToReturn: [Activity] = []
    
    func fetchAllActivities() -> [Activity] {
        return activitiesToReturn
    }
}


final class GenerateDailySuggestionTests: XCTestCase {
    
    var mockRepository: MockActivityRepository!
    
    override func setUp() {
        super.setUp()
        // Isso é executado antes de cada teste
        mockRepository = MockActivityRepository()
    }
    
    override func tearDown() {
        // Isso é executado depois de cada teste
        mockRepository = nil
        super.tearDown()
    }

    // Teste se as sugestões são relevantes para o objetivo do usuário.
    func test_generateDailySuggestions_returnsSuggestionsWithMatchingGoals() {
        // Arrange (Preparar)
        let user = MockData.usuarioFocadoEmMusculo // Objetivo: ganharMusculo
        mockRepository.activitiesToReturn = MockData.activities
        let options = SetOption(availableTime: nil, goals: nil, intensity: nil, locations: nil)
        
        // Act (Agir)
        let suggestions = SuggestionEngine.generateDailySuggestions(user: user, options: options, repository: mockRepository)
        
        // Assert (Verificar)
        XCTAssertFalse(suggestions.isEmpty, "Deveria haver pelo menos uma sugestão.")
        // Verifica se TODAS as sugestões têm PELO MENOS UM objetivo em comum com o usuário.
        XCTAssertTrue(suggestions.allSatisfy { suggestion in
            !Set(suggestion.goals).isDisjoint(with: Set(user.goals))
        })
    }
    
    // Teste se o tempo disponível é respeitado.
    func test_generateDailySuggestions_respectsAvailableTime() {
        // Arrange
        var user = MockData.usuarioSemPreferencias // availableTime = 30
        mockRepository.activitiesToReturn = MockData.activities
        let options = SetOption(availableTime: 15, goals: nil, intensity: nil, locations: nil) // Opção de 15 min
        
        // Act
        let suggestions = SuggestionEngine.generateDailySuggestions(user: user, options: options, repository: mockRepository)
        
        // Assert
        XCTAssertTrue(suggestions.allSatisfy { $0.minTime <= 15 })
    }
    
    // Teste se apenas as atividades preferidas do usuário são consideradas.
    func test_generateDailySuggestions_whenUserHasPreferredActivities_considersOnlyThem() {
        // Arrange
        let user = MockData.usuarioFocadoEmMusculo // Só gosta de Musculação
        mockRepository.activitiesToReturn = MockData.activities
        let options = SetOption(availableTime: nil, goals: nil, intensity: nil, locations: nil)

        // Act
        let suggestions = SuggestionEngine.generateDailySuggestions(user: user, options: options, repository: mockRepository)

        // Assert
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?.name, "Musculação")
    }
}
