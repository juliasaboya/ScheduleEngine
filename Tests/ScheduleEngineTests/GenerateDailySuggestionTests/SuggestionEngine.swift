//
//  SuggestionEngine.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 03/10/25.
//
import Foundation

class SuggestionEngine {
    
    static func generateDailySuggestions(
        user: User,
        options: SetOption,
        repository: ActivityRepositoryProtocol
    ) -> [Activity] {
        
        // 1. Unificar preferências.
        let goals = options.goals ?? user.goals
        let locations = options.locations ?? user.locations
        let intensity = options.intensity ?? user.intensity
        let availableTime = options.availableTime ?? user.availableTime
        

        let allActivities = repository.fetchAllActivities()
        
        // 2. Determinar quais atividades considerar.
        let activitiesToConsider: [Activity]
        if !user.activitiesIDs.isEmpty {
            // Se o usuário tem IDs preferidos, filtrar o universo total de atividades por esses IDs.
            let userPreferredIDs = Set(user.activitiesIDs)
            activitiesToConsider = allActivities.filter { userPreferredIDs.contains($0.id) }
        } else {
            // Se não, considerar todas as atividades.
            activitiesToConsider = allActivities
        }
        
        // 3. Algoritmo de pontuação e filtragem.
        let scoredActivities = activitiesToConsider.compactMap { activity -> (activity: Activity, score: Int)? in
            guard activity.minTime <= availableTime else { return nil }
            
            var score = 0
            let userGoalsSet = Set(goals)
            let matchingGoalsCount = activity.goals.filter { userGoalsSet.contains($0) }.count
            score += matchingGoalsCount * 10
            
            let userLocationsSet = Set(locations)
            let hasLocationMatch = !activity.locations.filter { userLocationsSet.contains($0) }.isEmpty
            if hasLocationMatch { score += 5 }
            
            let intensityDifference = abs(intensity.rawValue - activity.intensity.rawValue)
            if intensityDifference == 0 { score += 5 }
            else if intensityDifference == 1 { score += 2 }
            
            guard score > 0 else { return nil }
            return (activity: activity, score: score)
        }
        
        // 4. Ordena e retorna as 4 melhores.
        let sortedSuggestions = scoredActivities.sorted { $0.score > $1.score }
        let top4Activities = sortedSuggestions.prefix(4).map { $0.activity }
        
        return top4Activities
    }
}
