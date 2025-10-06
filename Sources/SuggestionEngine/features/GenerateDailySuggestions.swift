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
        limit: Int? = 4
    ) -> [SuggestedActivity<A>] where R.ActivityType == A {
        
        // 1. Unificar preferências.
        let goals = options.goals ?? user.goals
        let locations = options.locations ?? user.locations
        let intensity = options.intensity ?? user.intensity
        let availableTime = options.availableTime ?? user.availableTime
        

        let allActivities = repository.fetchAllActivities()
        
        // 2. Determina quais atividades considerar.
        let activitiesToConsider: [A]
        if !user.activitiesIDs.isEmpty {
            // Se o usuário tem IDs preferidos, filtra o universo total de atividades por esses IDs.
            let userPreferredIDs = Set(user.activitiesIDs)
            activitiesToConsider = allActivities.filter { userPreferredIDs.contains($0.id) }
        } else {
            // Se não, considera todas as atividades.
            activitiesToConsider = allActivities
        }
        
        // 3. Algoritmo de pontuação e filtragem.
        let scoredActivities = activitiesToConsider.compactMap { activity -> (activity: SuggestedActivity<A>, score: Int)? in
            guard activity.minTime <= availableTime else { return nil }
            
            let suggestedDuration = min(availableTime, activity.maxTime)
            var score = 0
            
            // Pontuação por objetivos (Peso 10)
            let userGoalsSet = Set(goals)
            let matchingGoalsCount = activity.goals.filter { userGoalsSet.contains($0) }.count
            score += matchingGoalsCount * 10
            
            // Pontuação por local (Peso 5)
            let userLocationsSet = Set(locations)
            let hasLocationMatch = !activity.locations.filter { userLocationsSet.contains($0) }.isEmpty
            if hasLocationMatch { score += 5 }
            
            // Pontuação por intensidade (Peso 5 para exato, 2 para próximo)
            let intensityDifference = abs(intensity.rawValue - activity.intensity.rawValue)
            if intensityDifference == 0 { score += 5 }
            else if intensityDifference == 1 { score += 2 }
            
            guard score > 0 else { return nil }
            
            let suggestedActivity = SuggestedActivity(activity: activity, suggestedDuration: suggestedDuration)
            return (activity: suggestedActivity, score: score)
        }
        
        // 4. Ordena e retorna as 4 melhores.
        let sortedSuggestions = scoredActivities.sorted { $0.score > $1.score }
        
        if let limit = limit {
            let suggestions = Array(sortedSuggestions.prefix(limit).map { $0.activity })
            return suggestions
        } else {
            let suggestions = sortedSuggestions.map { $0.activity }
            return suggestions
        }
    }
}
