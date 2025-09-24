//
//  recalculateDaySchedule.swift
//  ScheduleEngine
//
//  Created by Vinicius Gabriel on 24/09/25.
//

import Foundation

public extension ScheduleEngine {
    func recalcDayActivities<A: SchedulableActivity, S: ScheduleSlot>(
        dayToRecalc: Date,
        originalPlan: [PlannedActivity],
        currentBucket: [Date: [PlannedActivity]], // todos os dias já planejados
        slotsByDay: [Date: [S]],                   // slots disponíveis por dia
        userGoals: Set<A.Goal>,
        activityLocations: Set<A.LocationType>,
        loadActivities: (String) -> A?,            // como recuperar atividade original
        options: EngineOptions,
        excludedHandling: ExcludedHandling,
        calendar: Calendar = .current
    ) throws -> [Date: [PlannedActivity]] {
        
        var bucket = currentBucket
        let planned = originalPlan
        
        // 1) Carregar atividades originais
        let activities: [A] = planned.compactMap { loadActivities($0.activityName(from: [:])) }
        
        // 2) Tentar recalcular no mesmo dia
        if let slots = slotsByDay[calendar.startOfDay(for: dayToRecalc)] {
            let newPlan = try generateDailySchedule(
                day: dayToRecalc,
                slots: slots,
                userGoals: userGoals,
                activityLocations: activityLocations,
                userList: activities,
                options: options
            )
            
            let totalMinutes = newPlan.reduce(0, {$0 + $1.plannedMinutes })
            if totalMinutes <= options.dailyMaximumMinutes {
                bucket[dayToRecalc] = newPlan
                return bucket
            }
        }
        
        // 3) Se não couber, verificar política
        switch excludedHandling {
        case .drop:
            
            return bucket
            
        case .reschedule, .auto:
            // auto só força se dailyMinimum for "padrão crítico"
            if excludedHandling == .auto && options.dailyMinimumMinutes > 30 {
                break
            }
            
            // Tentar realocar em outro dia que não ultrapasse limite
            for (otherDay, slots) in slotsByDay where otherDay != calendar.startOfDay(for: dayToRecalc) {
                let existingMinutes = bucket[otherDay]?.reduce(0,{ $0 + $1.plannedMinutes }) ?? 0
                let remainingCapacity = options.dailyMaximumMinutes - existingMinutes
                
                guard remainingCapacity > 0 else { continue }
                
                let newPlan = try generateDailySchedule(
                    day: otherDay,
                    slots: slots,
                    userGoals: userGoals,
                    activityLocations: activityLocations,
                    userList: activities,
                    options: options
                )
                
                let newMinutes = newPlan.reduce(0, {$0 + $1.plannedMinutes })
                if newMinutes <= remainingCapacity {
                    bucket[dayToRecalc] = [] // limpa o antigo
                    bucket[otherDay, default: []].append(contentsOf: newPlan)
                    return bucket
                }
            }
        }
        
        // 4) Se não encontrou encaixe, mantém como estava
        return bucket
    }
}
