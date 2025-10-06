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
}
