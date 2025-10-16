//
//  Goal.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Enums

// Objetivos
public enum Goal: Int16, Codable, Sendable, CaseIterable {
    case loseWeight = 0
    case gainMuscle = 1
    case improveCondition = 2
    case flexibility = 3

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int16.self) {
            self = Goal(rawValue: intValue) ?? .improveCondition
        } else if let stringValue = try? container.decode(String.self) {
            switch stringValue {
            case "loseWeight": self = .loseWeight
            case "gainMuscle": self = .gainMuscle
            case "improveCondition": self = .improveCondition
            case "flexibility": self = .flexibility
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Valor inválido: \(stringValue)")
            }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Tipo inválido para Goal")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}



