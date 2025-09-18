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
    
    func buildWeeklySchedule<S: ScheduleSlot>(days: ClosedRange<Date>, slotsByDay: [Date: [S]], plansByDay: [Date: [PlannedActivity]], candidates: ((Date) -> Bool)? = nil, calendar: Calendar = .current, locale: Locale = Locale(identifier: "pt_BR")) -> [Date: (label: String, items: [(time: String, activity: String)])] {

      // 1) Lista de dias normalizados e filtrados
      let dayKeys: [Date] = {
        var out: [Date] = []
        var cur = calendar.startOfDay(for: days.lowerBound)
        let end = calendar.startOfDay(for: days.upperBound)
        while cur <= end {
          let include = candidates?(cur) ?? true
          if include { out.append(cur) }
          guard let next = calendar.date(byAdding: .day, value: 1, to: cur) else { break }
          cur = next
        }
        return out
      }()

      // 2) Para cada dia: montar label + parear atividades aos horários dos slots
      var result: [Date: (label: String, items: [(time: String, activity: String)])] = [:]

      for day in dayKeys {
        // label "Segunda-feira, 23/09/2025"
        let label = weekdayLabel(for: day, calendar: calendar, locale: locale)

        // Índice slotId -> range para achar horário da atividade
        let slots = (slotsByDay[day] ?? []).sorted { $0.range.start < $1.range.start }
        let slotById: [UUID: TimeRange] = Dictionary(uniqueKeysWithValues: slots.map { ($0.id, $0.range) })

        // Pegar apenas atividades planejadas para este dia
        let todaysPlan = (plansByDay[day] ?? [])

        // Itens: (HH:mm–HH:mm, nome)
        var items: [(String, String)] = []

        // Ordena por horário do slot (quando possível) para exibir cronológico
        let sortedPlan = todaysPlan.sorted { a, b in
          let ra = slotById[a.slotId]?.start ?? .distantFuture
          let rb = slotById[b.slotId]?.start ?? .distantFuture
          return ra < rb
        }

        for p in sortedPlan {
          if let range = slotById[p.slotId] {
            let time = timeSignature(of: range, calendar: calendar)
            items.append((time, p.activityName))
          } else {
            // Caso raro: activity aponta para um slotId que não existe no dia
            items.append(("--:--–--:--", p.activityName))
          }
        }

        result[day] = (label, items)
      }

      return result
    }
}
