//
//  GenerateDailySuggestions.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//

extension SuggestionEngineService {
    
    /// - Parameters:
    ///   - user: Um objeto que conforma com `UserProtocol`, contendo as preferências do usuário.
    ///   - options: Um `SetOption` com valores que sobrepõem temporariamente as preferências do usuário.
    ///   - repository: Um objeto que conforma com `ActivityRepositoryProtocol` e fornece as atividades.
    /// - Returns: Um array de `SuggestedActivity` contendo as melhores sugestões ordenadas por relevância.

    public static func generateDailySuggestions<U: UserProtocol, A: ActivityProtocol, R: ActivityRepositoryProtocol>(
        user: U,
        options: SetOption,
        repository: R,
        limit: Int? = 4,
        scoringWeight: ScoringWeights? = nil
    ) -> [SuggestedActivity<A>] where R.ActivityType == A {
        
        let weights = scoringWeight ?? ScoringWeights.default
        
        // 1. Unificar preferências.
        let goals = options.goals ?? user.goals
        let locations = options.locations ?? user.locations
        let intensity = options.intensity
        let availableTime = options.availableTime ?? user.availableTime
        
        // 2. Buscar todas as atividades.
        let allActivities = repository.catalog()
        
        // 3. Determina quais atividades considerar.
        let activitiesToConsider: [A]
        if !user.activitiesIDs.isEmpty {
            let userPreferredIDs = Set(user.activitiesIDs)
            activitiesToConsider = allActivities.filter { userPreferredIDs.contains($0.id) }
        } else {
            activitiesToConsider = allActivities
        }
        
        // 4. Algoritmo de pontuação e filtragem.
        let scoredActivities = activitiesToConsider.compactMap { activity -> (activity: SuggestedActivity<A>, score: Int)? in
            guard activity.minTime <= availableTime else { return nil }
            
            let suggestedDuration = min(availableTime, activity.maxTime)
            var score = 0
            
            // Pontuação por objetivos (Peso 10)
            let userGoalsSet = Set(goals)
            let matchingGoalsCount = activity.goals.filter { userGoalsSet.contains($0) }.count
            score += matchingGoalsCount * weights.goalMatch
            
            // Pontuação por local (Peso 5)
            let userLocationsSet = Set(locations)
            let hasLocationMatch = !activity.locations.filter { userLocationsSet.contains($0) }.isEmpty
            if hasLocationMatch { score += weights.locationMatch }
            
            // Pontuação por intensidade (Peso 5 para exato, 2 para próximo)
            if let userIntensity = intensity {
                let intensityDifference = abs(userIntensity.rawValue - activity.intensity.rawValue)
                if intensityDifference == 0 { score += weights.exactIntensityMatch }
                else if intensityDifference == 1 { score += weights.adjacentIntensityMatch }
            }
            
            guard score > 0 else { return nil }
            
            let suggestedActivity = SuggestedActivity(activity: activity, suggestedDuration: suggestedDuration)
            return (activity: suggestedActivity, score: score)
        }
        
        // 4. Ordena e retorna as 4 melhores.
        let sortedSuggestions = scoredActivities
            .sorted { $0.score > $1.score }
            .map {  $0.activity }
        
        return sortedSuggestions

    }
}

