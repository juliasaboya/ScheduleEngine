//
//  generateDaily.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 23/09/25.
//

import Foundation
public extension ScheduleEngine {

    /// Gera um cronograma de atividades ([PlannedActivity]) para um dia específico considerando uma coleção de janelas de horário e objetivos do usuário.

    func generateDailySchedule<A: SchedulableActivity, S: ScheduleSlot>(
        day: Date,
        slots: [S],
        userGoals: Set<A.Goal>,
        activityLocations: Set<A.LocationType>,
        userList: [A],
        options: EngineOptions = .init(dailyMinimumMinutes: 30, dailyMaximumMinutes: 50)
    ) throws -> [PlannedActivity] {

        guard !slots.isEmpty else { throw ScheduleEngineError.noSlots }
        guard !userList.isEmpty else { throw ScheduleEngineError.noActivities }

        let dailyMin = options.dailyMinimumMinutes
        let dailyMax = max(options.dailyMaximumMinutes, dailyMin)

        func slotMinutes(_ s: S) -> Int {
            let secs = s.range.end.timeIntervalSince(s.range.start)
            return max(0, Int(secs / 60))
        }

        var minutesPlanned = 0
        var plan: [PlannedActivity] = []

        var lastChosenId: UUID? = nil

        let totalSlotsMinutes = slots.reduce(0) { $0 + slotMinutes($1) }
        guard totalSlotsMinutes >= dailyMin else {
            throw ScheduleEngineError.slotsMinutesNotEnough
        }

        for slot in slots {
            let availableSlotMinutes = slotMinutes(slot)
            guard availableSlotMinutes > 0 else { continue }

            let remainingToMin = max(0, dailyMin - minutesPlanned)
            let remainingToMax = max(0, dailyMax - minutesPlanned)
            guard remainingToMax > 0 else { break }

            let baseCandidates = userList.filter { $0.minDuration <= min(availableSlotMinutes, remainingToMax) }
            guard !baseCandidates.isEmpty else { continue }

            let nonRepeating = baseCandidates.filter { $0.id != lastChosenId }
            let candidates = nonRepeating.isEmpty ? baseCandidates : nonRepeating


            func score(_ a: A) -> Int {
                let matches = a.goals.intersection(userGoals).count
                var sc = matches * 100
                let upperBound = min(availableSlotMinutes, a.maxDuration, remainingToMax)
                let contributes = min(upperBound, max(a.minDuration, remainingToMin))
                sc += contributes

                return sc
            }

            /// notação para escolher o candidato de maior score
            guard let chosen = candidates.max(by: { score($0) < score($1) }) else { continue }

            let activityMin = chosen.minDuration
            let activityMax = chosen.maxDuration

            /// determina o máximo tempo que pode ser alocado pra uma atividade dentre
            /// -
            let slotMaxPossibleDuration = min(availableSlotMinutes, activityMax, remainingToMax)
            guard slotMaxPossibleDuration >= activityMin else { continue }

            let plannedDuration: Int = {
                if remainingToMin > 0 {
                    return min(slotMaxPossibleDuration, max(activityMin, remainingToMin))
                } else {
                    return min(slotMaxPossibleDuration, activityMin)
                }
            }()


            plan.append(.init(activityId: chosen.id, slotId: slot.id, plannedMinutes: plannedDuration))

            /// minutesPlanned tem que estar entre 30 e 50 minutos
            minutesPlanned += plannedDuration
            lastChosenId = chosen.id

        }

        return plan
    }
}
