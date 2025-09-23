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
    
// 
    
    enum ExcludedHandling {
       case auto        // regra: força reposição se daysToPlan == 3; caso contrário, não força
       case reschedule  // sempre força reposição até atingir o total (se houver dias livres)
       case drop        // nunca força reposição (aceita menos dias)
     }

    func buildWeeklySchedule(
        plannedTemplate: [PlannedActivity],
        slotsById templateSlotsById: [UUID: TimeRange],
        startDate: Date,
        endDate: Date,
        daysToPlan rawDaysToPlan: Int = 4,
        allowedWeekdays: Set<Int>? = nil,
        excludedDays: Set<Date> = [],
        calendar inCal: Calendar = Calendar(identifier: .gregorian),
        timeZone: TimeZone = .current,
        templateTimeZone: TimeZone? = nil,
        excludedHandling: ExcludedHandling = .auto
      ) -> (bucket: [Date: [PlannedActivity]], replicatedSlotsById: [UUID: TimeRange]) {

        // Calendário DESTINO (plano final)
        var cal = inCal
        cal.timeZone = timeZone

        // Calendário ORIGEM (template)
        var srcCal = inCal
        srcCal.timeZone = templateTimeZone ?? timeZone

        // Clamp do total de dias: agora 3…6
        let k = max(3, min(6, rawDaysToPlan))

        let interval = DateInterval(start: startDate, end: endDate)
        func sod(_ d: Date) -> Date { cal.startOfDay(for: d) }

        // Normaliza exclusões para início do dia no fuso DESTINO
        let normalizedExcluded = Set(excludedDays.map { sod($0) })

        // 1) Coletar **todos** os candidatos na janela (respeitando allowedWeekdays).
        //    (Não removemos excluídos aqui; a exclusão será aplicada **depois** da seleção.)
        var allCandidates: [Date] = []
        var cursor = sod(startDate)
        let endDay = sod(endDate)

        while cursor < endDay {
          if interval.contains(cursor) {
            if let allowed = allowedWeekdays {
              let wd = cal.component(.weekday, from: cursor) // 1...7
              if allowed.contains(wd) { allCandidates.append(cursor) }
            } else {
              allCandidates.append(cursor)
            }
          }
          guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
          cursor = next
        }

        guard !allCandidates.isEmpty else { return ([:], [:]) }

          // 2) Seleciona k dias intercalados (centralizado em cada faixa)
          let n = allCandidates.count
          guard k > 0 else { return ([:], [:]) }

          let step = Double(n) / Double(k)
          var pickedDays: [Date] = (0..<k).map { i in
            let pos = (Double(i) + 0.5) * step // centrado
            let idx = min(n - 1, Int(floor(pos)))
            return allCandidates[idx]
          }

        // De-dupe preservando ordem
        var uniquePicked: [Date] = []
        uniquePicked.reserveCapacity(pickedDays.count)
        for d in pickedDays where !uniquePicked.contains(d) { uniquePicked.append(d) }
        pickedDays = uniquePicked

        // 3) Aplica EXCLUSÃO **após** a seleção (para que `.drop` possa reduzir o total).
        var finalDays: [Date] = pickedDays.filter { !normalizedExcluded.contains($0) }

        // 4) Preenche (remaneja) conforme política.
        let mustBackfill: Bool = {
          switch excludedHandling {
          case .reschedule: return true                 // sempre tenta completar
          case .drop:       return false                // nunca completa
          case .auto:       return (k == 3)             // só completa quando k==3
          }
        }()

        if mustBackfill, finalDays.count < k {
          for d in allCandidates where !normalizedExcluded.contains(d) && !finalDays.contains(d) {
            finalDays.append(d)
            if finalDays.count == k { break }
          }
        }

        // 5) Replica atividades para os dias finais (preserva horário do template via templateTimeZone).
        var replicatedSlotsById: [UUID: TimeRange] = [:]
        var bucket: [Date: [PlannedActivity]] = [:]

        for day in finalDays {
          for p in plannedTemplate {
            guard let tr = templateSlotsById[p.slotId] else { continue }

            // Lê componentes no fuso do template (origem)
            let comps = srcCal.dateComponents([.hour, .minute, .second], from: tr.start)
            let h = comps.hour ?? 0
            let m = comps.minute ?? 0
            let s = comps.second ?? 0

            // Reconstrói no fuso de destino (mesmo "wall-clock")
            guard let newStart = cal.date(bySettingHour: h, minute: m, second: s, of: day) else { continue }
            let duration = tr.end.timeIntervalSince(tr.start)
            let newEnd = newStart.addingTimeInterval(duration)

            let newSlotId = UUID()
            replicatedSlotsById[newSlotId] = TimeRange(start: newStart, end: newEnd)

            bucket[day, default: []].append(
              PlannedActivity(activityName: p.activityName, duration: p.duration, slotId: newSlotId)
            )
          }
        }

        // 6) Ordena atividades de cada dia pelo horário de início do slot
        for (day, list) in bucket {
          bucket[day] = list.sorted {
            guard let sa = replicatedSlotsById[$0.slotId]?.start,
                  let sb = replicatedSlotsById[$1.slotId]?.start else { return false }
            return sa < sb
          }
        }

        return (bucket, replicatedSlotsById)
      }
}
