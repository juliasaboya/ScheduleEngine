//
//  ScoringWeights.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Configuration

/// Define os pesos para o cálculo da pontuação de uma atividade.
/// Isso permite que o algoritmo de sugestão seja personalizado pelo consumidor do package.
public struct ScoringWeights {
    let goalMatch: Int
    let locationMatch: Int
    let exactIntensityMatch: Int
    let adjacentIntensityMatch: Int

    /// Pesos padrão
    public static var `default`: ScoringWeights {
        ScoringWeights(
            goalMatch: 10,
            locationMatch: 5,
            exactIntensityMatch: 5,
            adjacentIntensityMatch: 2
        )
    }
    
    public init(goalMatch: Int, locationMatch: Int, exactIntensityMatch: Int, adjacentIntensityMatch: Int) {
        self.goalMatch = goalMatch
        self.locationMatch = locationMatch
        self.exactIntensityMatch = exactIntensityMatch
        self.adjacentIntensityMatch = adjacentIntensityMatch
    }
}

