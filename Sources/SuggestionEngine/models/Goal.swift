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
    case improveFitness = 2
    case increaseFlexibilityAndMobility = 3
    case healthAndWellBeing = 4
    case socialization = 5

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int16.self) {
            self = Goal(rawValue: intValue) ?? .healthAndWellBeing
        } else if let stringValue = try? container.decode(String.self) {
            switch stringValue {
            case "loseWeight": self = .loseWeight
            case "gainMuscle": self = .gainMuscle
            case "improveFitness": self = .improveFitness
            case "increaseFlexibilityAndMobility": self = .increaseFlexibilityAndMobility
            case "healthAndWellBeing": self = .healthAndWellBeing
            case "socialization": self = .socialization
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



