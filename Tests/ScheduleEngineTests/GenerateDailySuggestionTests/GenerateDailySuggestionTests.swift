//
//  GenerateDailySuggestionTests.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 01/10/25.
//

import XCTest
@testable import ScheduleEngine

final class MockDataTests: XCTestCase {
    
/// RED:
    
    // teste se as atividades sugeridas estão de acordo com o objetivo do usuário
    func test_generateDailySuggestions_matchesUserObjective() {
        let user = MockData.user // objetivos = .ganharMusculo
        
        let suggestions = MockData.generateDailySuggestions(for: user)
        
        for suggestion in suggestions {
            XCTAssertTrue(suggestion.objetivos.contains(user.objetivos),
                          "A sugestão deve atender aos objetivos do usuário")
        }
    }
    
    // teste se as atividades sugeridas tem duração mínima compatível com o tempo do usuário.
    func test_generateDailySuggestions_respectsAvailableTime() {
        let user = MockData.user // tempoDisponível = 30

        let suggestions = MockData.generateDailySuggestions(for: user)

        for suggestion in suggestions {
            XCTAssertTrue(suggestion.tempoMin <= user.tempoDisponível && suggestion.tempoMax >= user.tempoDisponível,
                          "A sugestão deve caber no tempo disponível do usuário")
        }
    }
    
    // teste se as atividades sugeridas podem ser realizadas no local do usuário
    func test_generateDailySuggestions_matchesUserLocation() {
        let user = MockData.user
        
        let suggestions = MockData.generateDailySuggestions(for: user)
        
        for suggestion in suggestions {
            XCTAssertTrue(suggestion.local.contains(user.local),
                          "A sugestão deve ser compatível com o local do usuário")
        }
    }
    
    // teste se as atividades sugeridas têm a intensidade compatível com o desejo do usuário
    func test_generateDailySuggestions_matchesUserIntensity() {
        let user = MockData.user
        
        let suggestions = MockData.generateDailySuggestions(for: user)
        
        for suggestion in suggestions {
            XCTAssertEqual(suggestion.intensidade, user.intensidade,
                           "A sugestão deve ter a intensidade desejada pelo usuário")
        }
    }
    
    
    // teste se as atividades sugeridas fazem parte das atividades do usuário
    func test_generateDailySuggestions_onlyIncludesUserActivities() {
        let user = MockData.user

        let suggestions = MockData.generateDailySuggestions(for: user)

        for suggestion in suggestions {
            XCTAssertTrue(user.activities.contains(suggestion.id),
                          "A sugestão deve ser de uma atividade que o usuário pode realizar")
        }
    }
}
