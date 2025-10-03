//
//  ModelTests.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 03/10/25.
//
import Foundation

// MARK: - Enums

// Locais
public enum Location: String, Codable, Sendable {
    case home, gym, work, outdoor
}

// Objetivos
public enum Goal: String, Codable, Sendable {
    case loseWeight, gainMuscle, improveFitness, IncreaseFlexibilityAndMobility, healthAndWellBeing, socialization
}

// Intensidades
public enum Intensity: Int, Comparable, CaseIterable, Sendable {
    case low = 1, medium = 2, high = 3
    public static func < (lhs: Intensity, rhs: Intensity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Parameter & Return Types

// Estrutura para passar opções de UI que sobrepõem as preferências do usuário.
public struct SetOption: Sendable {
    public var availableTime: Int?
    public var goals: [Goal]?
    public var intensity: Intensity?
    public var locations: [Location]?
    
    public init(availableTime: Int? = nil, goals: [Goal]? = nil, intensity: Intensity? = nil, locations: [Location]? = nil) {
        self.availableTime = availableTime
        self.goals = goals
        self.intensity = intensity
        self.locations = locations
    }
}

// O objeto de retorno final: uma atividade com uma duração específica sugerida.
public struct SuggestedActivity<ActivityType: ActivityProtocol> {
    public let activity: ActivityType
    public let suggestedDuration: Int
    
    public init(activity: ActivityType, suggestedDuration: Int) {
        self.activity = activity
        self.suggestedDuration = suggestedDuration
    }
}
