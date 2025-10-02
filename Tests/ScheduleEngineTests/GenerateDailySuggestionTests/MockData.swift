//
//  MockData.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 01/10/25.
//
import Foundation

struct MockData {
    // Usuário
    struct User {
        let tempoDisponível: Int
        let objetivos: Objectives
        let intensidade: Intensity
        let local: Location
        let activities: [UUID]
    }
    
    // Atividades
    struct Activity {
        let id: UUID
        let nome: String
        let objetivos: [Objectives]
        let intensidade: Intensity
        let local: [Location]
        let tempoMin: Int
        let tempoMax: Int
        var isActive: Bool
    }
    
    // Locais
    enum Location: String, Codable {
        case casa, academia, arLivre
    }
    
    // Objetivos
    enum Objectives: String, Codable {
        case ganharPeso, perderPeso, ganharMusculo
    }
    
    // Intensidades
    enum Intensity: String, Codable {
        case baixa, média, alta
    }
    
    static let user: User = User(
        tempoDisponível: 30,
        objetivos: .ganharMusculo,
        intensidade: .média,
        local: .casa,
        activities: userActivitiesIDs
    )
    
    static let activities: [Activity] = [
        Activity(
            id: UUID(),
            nome: "Musculação",
            objetivos: [.ganharMusculo],
            intensidade: .média,
            local: [.academia],
            tempoMin: 20,
            tempoMax: 70,
            isActive: true
        ),
        Activity(
            id: UUID(),
            nome: "Ballet",
            objetivos: [.ganharPeso],
            intensidade: .média,
            local: [.arLivre],
            tempoMin: 15,
            tempoMax: 50,
            isActive: false
        ),
        Activity(
            id: UUID(),
            nome: "Pilates",
            objetivos: [.perderPeso],
            intensidade: .alta,
            local: [.casa],
            tempoMin: 30,
            tempoMax: 40,
            isActive: false
        )
    ]
    
    static var userActivities: [Activity] {
        activities.filter { $0.isActive }
    }
    
    static var userActivitiesIDs: [UUID] {
        userActivities.map { $0.id }
    }
    
    static func generateDailySuggestions(for: User) -> [Activity] {
        //
        return []
    }
}
