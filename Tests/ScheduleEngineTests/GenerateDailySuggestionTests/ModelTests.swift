//
//  ModelTests.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 03/10/25.
//
import Foundation

// Usuário
struct User {
    let availableTime: Int
    let goals: [Goal]
    let intensity: Intensity
    let locations: [Location]
    let activitiesIDs: [UUID]
}

// Atividades
struct Activity {
    let id: UUID
    let name: String
    let goals: [Goal]
    let intensity: Intensity
    let locations: [Location]
    let minTime: Int
    let maxTime: Int
}

// Opções da UI
struct SetOption {
    let availableTime: Int?
    let goals: [Goal]?
    let intensity: Intensity?
    let locations: [Location]?
}

// Locais
enum Location: String, Codable {
    case casa, academia, arLivre
}

// Objetivos
enum Goal: String, Codable {
    case ganharPeso, perderPeso, ganharMusculo
}

// Intensidades
enum Intensity: Int, Comparable, CaseIterable {
    case low = 1, medium = 2, high = 3
    static func < (lhs: Intensity, rhs: Intensity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
