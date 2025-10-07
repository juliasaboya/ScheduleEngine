//
//  Intensity.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Enums

// Intensidades
public enum Intensity: Int16, Comparable, CaseIterable, Sendable {
    case low = 1, medium = 2, high = 3
    public static func < (lhs: Intensity, rhs: Intensity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int16.self) {
            self = Intensity(rawValue: intValue) ?? .low
        } else if let stringValue = try? container.decode(String.self) {
            switch stringValue {
            case "low": self = .low
            case "medium": self = .medium
            case "high": self = .high
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
