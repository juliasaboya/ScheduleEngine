//
//  generateWeekly.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 23/09/25.
//

import Foundation

public extension ScheduleEngine {
    
    /// Constrói um planejamento semanal a partir de um **template diário** de atividades,
    /// replicando as atividades (e seus horários) para `k` dias distribuídos dentro de um
    /// intervalo `[startDate, endDate)`, respeitando dias permitidos, exclusões de dias,
    /// fuso horário de destino e fuso do template.
    ///
    /// A seleção de dias funciona assim:
    /// - Calcula todos os dias candidatos na janela, no fuso de **destino** (`timeZone`),
    ///   opcionalmente filtrando por `allowedWeekdays`.
    /// - Seleciona `k` dias **intercalados** (espalhados de forma uniforme e centralizada nas faixas).
    /// - Aplica as **exclusões** somente após a seleção (para permitir que `.drop` reduza a contagem).
    /// - Dependendo de `excludedHandling`, pode **repor** (backfill) dias até atingir `k`.
    ///
    /// A replicação de horários funciona assim:
    /// - Cada `PlannedActivity` do `plannedTemplate` referencia um slot original em `templateSlotsById`.
    /// - Extrai `hour:minute:second` do início do slot no fuso de **origem** (`templateTimeZone` se definido; caso contrário, `timeZone`).
    /// - Reconstrói o mesmo horário de “parede” (wall-clock) no **dia de destino**, no fuso de **destino** (`timeZone`),
    ///   preservando a **duração** do slot.
    /// - Gera um **novo `UUID`** de slot para cada réplica e o devolve em `replicatedSlotsById`.
    ///
    /// - Parameters:
    ///   - plannedTemplate: Lista de atividades do **template** (cada item usa `slotId` para apontar o horário no template).
    ///   - templateSlotsById: Mapa de **slots do template** (`UUID` → `TimeRange`) que contém os horários originais.
    ///   - startDate: Início da janela (inclusive). A seleção percorre dias usando `startOfDay` no fuso de destino.
    ///   - endDate: Fim da janela (**exclusivo**). Dias iguais a `startOfDay(endDate)` não entram.
    ///   - rawDaysToPlan: Número desejado de dias a planejar. É **clampado para 3…6** internamente e passa a ser `k`.
    ///   - allowedWeekdays: Conjunto opcional de dias da semana permitidos (valores de `Calendar.component(.weekday)`, **1=Dom … 7=Sáb**).
    ///   - excludedDays: Conjunto de datas a excluir. Cada data é **normalizada** para `startOfDay` no fuso de destino antes da comparação.
    ///   - inCal: Calendário base (default: gregoriano). Será copiado e ajustado para o fuso de destino e origem conforme necessário.
    ///   - timeZone: **Fuso de destino** do planejamento (onde o bucket final é construído).
    ///   - templateTimeZone: **Fuso de origem** do template. Se `nil`, utiliza `timeZone`.
    ///   - excludedHandling: Política para lidar com dias **excluídos** após a seleção:
    ///       - `.reschedule`: sempre tenta repor (backfill) até atingir `k`.
    ///       - `.drop`: nunca repõe (o total pode ficar < `k`).
    ///       - `.auto`: repõe **apenas quando `k == 3`**.
    ///
    /// - Returns: Uma tupla com:
    ///   - `bucket`: `[Date: [PlannedActivity]]` — atividades replicadas agrupadas por **dia (startOfDay)** no fuso de destino.
    ///               As listas de cada dia são **ordenadas** pelo horário de início do slot.
    ///   - `replicatedSlotsById`: `[UUID: TimeRange]` — slots **novos** gerados na replicação (um UUID por réplica),
    ///               com `TimeRange` já no fuso de destino.
    ///
    /// - Important:
    ///   - O algoritmo de seleção usa distribuição **centralizada** para intercalar dias (evita pares consecutivos quando possível).
    ///   - `endDate` é **exclusivo**; use um dia a mais caso queira incluir o último dia integral.
    ///   - `excludedDays` é comparado após normalização para `startOfDay` no fuso de **destino**.
    ///   - `allowedWeekdays` usa a convenção de `Calendar`: **1=Domingo … 7=Sábado**.
    ///   - Essa função **não faz “escolha” de atividades** por metas/score; ela **replica** o template com novos slots.
    ///
    /// - Complexity:
    ///   - Construção de candidatos: O(d) onde d é o número de dias no intervalo.
    ///   - Replicação: O(d × p) onde p é o número de atividades no `plannedTemplate` (apenas para os dias selecionados).
    ///
    /// - Example:
    /// ```swift
    /// var cal = Calendar(identifier: .gregorian)
    /// cal.locale = Locale(identifier: "pt_BR")
    /// cal.timeZone = TimeZone(identifier: "America/Fortaleza")!
    ///
    /// // Janela: segunda 00:00 até próxima segunda 00:00 (exclusivo)
    /// let weekStart = cal.date(from: DateComponents(year: 2025, month: 9, day: 22))!  // seg
    /// let weekEnd   = cal.date(byAdding: .day, value: 7, to: weekStart)!
    ///
    /// // Template: duas atividades ancoradas em slots 18:30–19:00 e 20:00–20:20
    /// let slot1 = UUID(), slot2 = UUID()
    /// let templateSlots: [UUID: TimeRange] = [
    ///   slot1: TimeRange(start: cal.date(bySettingHour: 18, minute: 30, second: 0, of: weekStart)!,  // hora do template
    ///                    end:   cal.date(bySettingHour: 19,  minute: 0,  second: 0, of: weekStart)!),
    ///   slot2: TimeRange(start: cal.date(bySettingHour: 20, minute: 0,  second: 0, of: weekStart)!,
    ///                    end:   cal.date(bySettingHour: 20, minute: 20, second: 0, of: weekStart)!),
    /// ]
    ///
    /// let template: [PlannedActivity] = [
    ///   .init(activityName: "Leitura",     duration: 30, slotId: slot1),
    ///   .init(activityName: "Alongamento", duration: 20, slotId: slot2)
    /// ]
    ///
    /// // Planejar 4 dias intercalados, apenas em dias úteis, sem exclusões.
    /// let result = buildWeeklySchedule(
    ///   plannedTemplate: template,
    ///   slotsById: templateSlots,
    ///   startDate: weekStart,
    ///   endDate: weekEnd,
    ///   daysToPlan: 4,
    ///   allowedWeekdays: [2,3,4,5,6], // 2=Seg … 6=Sex
    ///   excludedDays: [],
    ///   calendar: cal,
    ///   timeZone: cal.timeZone,
    ///   templateTimeZone: cal.timeZone,
    ///   excludedHandling: .drop
    /// )
    ///
    /// // result.bucket trará 4 dias (ex.: Seg, Qua, Sex, …), cada um com as duas atividades em ordem.
    /// // result.replicatedSlotsById conterá os novos slots (um UUID por réplica) com horários no fuso de destino.
    /// ```
    ///
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
                PlannedActivity(activityId: p.activityId, slotId: newSlotId, plannedMinutes: p.plannedMinutes)
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
