//
//  Goal.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Enums

// Objetivos
public enum Goal: Int16, Codable, Sendable {
    case loseWeight = 0
    case gainMuscle = 1
    case improveFitness = 2
    case increaseFlexibilityAndMobility = 3
    case healthAndWellBeing = 4
    case socialization = 5
}
