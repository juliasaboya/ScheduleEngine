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

    public static func generateDailySuggestions<U: UserProtocol, A: ActivityProtocol>(
        user: U,
        options: SetOption,
        activities: [A],
        scoringWeight: ScoringWeights? = nil
    ) -> [SuggestedActivity<A>] {
        
        let weights = scoringWeight ?? ScoringWeights.default

        // 1. Unificar preferências
        let goals = options.goals ?? user.goals
        let locations = options.locations ?? user.locations
        let intensity = options.intensity ?? user.intensity
        let availableTime = options.availableTime ?? user.availableTime

        // 2. Usa as atividades recebidas diretamente
        let allActivities = activities

        // 3. Determina quais atividades considerar
        let activitiesToConsider: [A]
        if !user.activitiesIDs.isEmpty {
            let userPreferredIDs = Set(user.activitiesIDs)
            activitiesToConsider = allActivities.filter { userPreferredIDs.contains($0.id) }
            print("USER ACTIVITIES IDS:", user.activitiesIDs.count)
        } else {
            activitiesToConsider = allActivities
            print("--> Pacote Considerou todas as atividades <--")
        }

        // 4. Algoritmo de pontuação e filtragem
        let scoredActivities = activitiesToConsider.compactMap { activity -> (SuggestedActivity<A>, Int)? in
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
            let userIntensity = intensity
            let intensityDifference = abs(userIntensity.rawValue - activity.intensity.rawValue)
            if intensityDifference == 0 { score += weights.exactIntensityMatch }
            else if intensityDifference == 1 { score += weights.adjacentIntensityMatch }

            guard score > 0 else { return nil }
            let suggestedActivity = SuggestedActivity(activity: activity, suggestedDuration: suggestedDuration)
            return (suggestedActivity, score)
        }

        // 5. Ordena e retorna
        return scoredActivities
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}

