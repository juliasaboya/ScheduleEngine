//
//  Location.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Enums

// Locais
public enum Location: Int16, Codable, Sendable {
    case home = 1, gym = 2, work = 3, outdoor = 4
}
