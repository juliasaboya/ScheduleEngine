//
//  SetOption.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Parameter & Return Types

// Estrutura para passar opções de UI que sobrepõem as preferências do usuário.
public struct SetOption: Sendable {
    public var availableTime: Int?
    public var goals: [Goal]?
    public var intensity: Intensity?
    public var locations: [LocationType]?
    
    public init(availableTime: Int? = nil, goals: [Goal]? = nil, intensity: Intensity? = nil, locations: [LocationType]? = nil) {
        self.availableTime = availableTime
        self.goals = goals
        self.intensity = intensity
        self.locations = locations
    }
}
