//
//  Location.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Enums

// Locais
public enum LocationType: Int16, Codable, Sendable, Identifiable {
    case home = 1, gym = 2, work = 3, outdoor = 4
    
    public var id: Int16 { self.rawValue }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int16.self) {
            self = LocationType(rawValue: intValue) ?? .home
        } else if let stringValue = try? container.decode(String.self) {
            switch stringValue {
            case "home": self = .home
            case "gym": self = .gym
            case "work": self = .work
            case "outdoor": self = .outdoor
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Valor inválido: \(stringValue)")
            }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Tipo inválido para LocationType")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
