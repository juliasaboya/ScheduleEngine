//
//  MockData.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 01/10/25.
//
import Foundation

struct MockData {
    
    // --- Usuários para diferentes cenários de teste ---
    static var usuarioFocadoEmMusculo: User {
        User(
            availableTime: 60,
            goals: [.ganharMusculo],
            intensity: .medium,
            locations: [.academia],
            activitiesIDs: [musculacao.id]
        )
    }
    
    static var usuarioSemPreferencias: User {
        User(
            availableTime: 30,
            goals: [.perderPeso],
            intensity: .low,
            locations: [.casa],
            activitiesIDs: []
        )
    }
    
    static let user: User = User(
        availableTime: 30,
        goals: [.ganharPeso],
        intensity: .medium,
        locations: [.casa],
        activitiesIDs: [ballet.id, musculacao.id, pilates.id]
    )
    
    // --- Atividades para usar nos mocks ---
    static let musculacao = Activity(id: UUID(), name: "Musculação", goals: [.ganharMusculo], intensity: .medium, locations: [.academia], minTime: 20, maxTime: 70)
    static let ballet = Activity(id: UUID(), name: "Ballet", goals: [.ganharPeso], intensity: .medium, locations: [.arLivre], minTime: 15, maxTime: 50)
    static let pilates = Activity(id: UUID(), name: "Pilates", goals: [.perderPeso], intensity: .high, locations: [.casa], minTime: 30, maxTime: 40)
    
    static let activities: [Activity] = [musculacao, ballet, pilates]
    
}
