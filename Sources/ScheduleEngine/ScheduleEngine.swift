// The Swift Programming Language
// https://docs.swift.org/swift-book

// RECEBE: Dias disponíveis, intervalos de tempo, objetivos e lista do usuário
// DEVOLVE: cronograma semanal OU diário com atividades (nome, duração, intensidade) em determinada janela de horário.
//func generateDailySchedule(day: Date, slots: Slot, userGoals: [Goal], userList: [Activity]) {
//
//}

import Foundation

public extension ScheduleEngine {
    func generateDailySchedule<A: SchedulableActivity, S: ScheduleSlot, G: Hashable>(day: Date, slots: [S], userGoals: Set<G>, userList: [A], options: EngineOptions = .init()) throws -> [PlannedActivity] where A.GoalType == G {

    guard !slots.isEmpty else { throw ScheduleEngineError.noSlots }
    guard !userList.isEmpty else { throw ScheduleEngineError.noActivities }

    func slotMinutes(_ s: S) -> Int {
      max(0, Int(s.range.end.timeIntervalSince(s.range.start) / 60))
    }

    var minutesPlanned = 0
    var lastActivityId: UUID? = nil
    var plan: [PlannedActivity] = []

    for slot in slots {
      let available = slotMinutes(slot)
      guard available > 0 else { continue }

      let candidates = userList.filter { $0.minDuration <= available }
      guard !candidates.isEmpty else { continue }

      let remainingToTarget = max(0, options.dailyMinimumMinutes - minutesPlanned)

      func score(_ a: A) -> Int {
        // 1) matching de goals
        let matches = a.goals.intersection(userGoals).count
        var sc = matches * 100

        // 2) encaixe no slot e contribuição pra meta
        let upperBound = min(available, a.maxDuration)
        let contributes = min(upperBound, max(a.minDuration, remainingToTarget))
        sc += contributes // quanto mais conseguir contribuir, melhor

        if options.avoidConsecutiveRepeat, a.id == lastActivityId { sc -= 10 }
        return sc
      }

      guard let chosen = candidates.maxBy(score) else { continue }

      // Define duração planejada:
      // - precisa respeitar minDuration e caber no slot/maxDuration
      // - tenta aproximar da meta diária com esse slot
      let upperBound = min(available, chosen.maxDuration)
      let lowerBound = chosen.minDuration

      let plannedDuration: Int = {
        guard upperBound >= lowerBound else { return lowerBound } // sanity
        if remainingToTarget > 0 {
          // tenta colocar o que falta, sem violar bounds
          return min(upperBound, max(lowerBound, remainingToTarget))
        } else {
          // meta já batida: usa o mínimo da atividade
          return min(upperBound, lowerBound)
        }
      }()

      guard plannedDuration >= lowerBound else { continue }

      plan.append(.init(activityName: chosen.name, duration: plannedDuration, slotId: slot.id))
      minutesPlanned += plannedDuration
      lastActivityId = chosen.id
    }

    return plan
  }
    
    func buildWeeklySchedule(
            planned: [PlannedActivity],
            slotsById: [UUID: TimeRange],
            startDate: Date,
            endDate: Date,
            allowedWeekdays: Set<Int>? = nil,
            calendar inCal: Calendar = Calendar(identifier: .gregorian),
            timeZone: TimeZone = .current
        ) -> [Date: [PlannedActivity]] {

            var cal = inCal
            cal.timeZone = timeZone

            let interval = DateInterval(start: startDate, end: endDate)

            func startOfDay(_ d: Date) -> Date { cal.startOfDay(for: d) }

            // Filtra atividades pelo intervalo + dias permitidos
            var bucket: [Date: [PlannedActivity]] = [:]

            for p in planned {
                guard let slot = slotsById[p.slotId] else { continue }
                let slotStart = slot.start

                // Dentro do intervalo?
                guard interval.contains(slotStart) else { continue }

                // Restringe por dia-da-semana se informado
                if let allowed = allowedWeekdays {
                    let wd = cal.component(.weekday, from: slotStart) // 1...7
                    guard allowed.contains(wd) else { continue }
                }

                // Agrupa pelo início do dia
                bucket[startOfDay(slotStart), default: []].append(p)
            }

            // Ordena as atividades de cada dia pelo horário de início do slot
            for (day, list) in bucket {
                let sorted = list.sorted { a, b in
                    guard let sa = slotsById[a.slotId]?.start,
                          let sb = slotsById[b.slotId]?.start else { return false }
                    return sa < sb
                }
                bucket[day] = sorted
            }

            return bucket
        }
}
