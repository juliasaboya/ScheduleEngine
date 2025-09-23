import XCTest
@testable import ScheduleEngine

final class ScheduleEngineTests: XCTestCase {
    
    // MARK: - buildWeeklySchedule (replicação 3–5 dias, weekdays e exclusões)
    
    func test_BuildWeeklySchedule_DefaultIsFourDays_ClampedBetween3And5() {
        // DESTINO: America/Fortaleza
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "pt_BR")
        cal.timeZone = TimeZone(identifier: "America/Fortaleza")!
        
        // Semana atual: segunda 00:00 → próxima segunda 00:00 (exclusiva)
        let todayStart = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: todayStart) // 1=dom ... 7=sáb
        let daysSinceMonday = (weekday - 2 + 7) % 7
        let weekStart = cal.date(byAdding: .day, value: -daysSinceMonday, to: todayStart)!
        let weekEnd   = cal.date(byAdding: .day, value: 7, to: weekStart)!
        let allWeekDays: [Date] = (0..<7).map { cal.startOfDay(for: cal.date(byAdding: .day, value: $0, to: weekStart)!) }
        
        // Template (helpers em UTC)
        let s1 = makeSlot(weekStart, startH: 18, startM: 30, endH: 19, endM: 0)
        let s2 = makeSlot(weekStart, startH: 20, startM: 0,  endH: 20, endM: 20)
        let plannedTemplate: [PlannedActivity] = [
            .init(activityName: "Leitura",     duration: 30, slotId: s1.id),
            .init(activityName: "Alongamento", duration: 20, slotId: s2.id),
        ]
        let slotsById: [UUID: TimeRange] = [s1.id: s1.range, s2.id: s2.range]
        
        // Executa (informando fuso do template = UTC)
        let engine = ScheduleEngine()
        let result = engine.buildWeeklySchedule(
            plannedTemplate: plannedTemplate,
            slotsById: slotsById,
            startDate: weekStart,
            endDate: weekEnd,
            daysToPlan: 4,                // default esperado
            allowedWeekdays: nil,
            excludedDays: [],
            calendar: cal,
            timeZone: cal.timeZone,
            templateTimeZone: TimeZone(secondsFromGMT: 0)!
        )
        
        // ASSERTS enxutos
        XCTAssertEqual(result.bucket.keys.count, 4, "Default deve replicar 4 dias.")
        XCTAssertTrue(result.bucket.keys.allSatisfy { $0 >= weekStart && $0 < weekEnd },
                      "Todos os dias devem estar dentro da semana atual.")
        
        // PRINT amigável (Seg→Dom), marcando PULADO
        print("\n--- DefaultIsFourDays (SEMANA ATUAL: Seg → Dom) ---")
        for day in allWeekDays {
            if let acts = result.bucket[day] {
                print(fmtDay(day, cal: cal))
                for a in acts { print(fmtActivity(a, slotsById: result.replicatedSlotsById, cal: cal)) }
            } else {
                print("\(fmtDay(day, cal: cal))  >> PULADO")
            }
        }
    }
    
    func test_BuildWeeklySchedule_PreservesTimesAndDurations() {
        // DESTINO: America/Fortaleza
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "pt_BR")
        cal.timeZone = TimeZone(identifier: "America/Fortaleza")!
        
        // Semana atual: segunda 00:00 → próxima segunda 00:00 (exclusiva)
        let todayStart = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: todayStart) // 1=dom ... 7=sáb
        let daysSinceMonday = (weekday - 2 + 7) % 7
        let weekStart = cal.date(byAdding: .day, value: -daysSinceMonday, to: todayStart)!
        let weekEnd   = cal.date(byAdding: .day, value: 7, to: weekStart)!
        let allWeekDays: [Date] = (0..<7).map { cal.startOfDay(for: cal.date(byAdding: .day, value: $0, to: weekStart)!) }
        
        // TEMPLATE EM UTC (helpers já criam em UTC)
        let s1 = makeSlot(weekStart, startH: 18, startM: 30, endH: 19, endM: 0)
        let s2 = makeSlot(weekStart, startH: 20, startM: 0,  endH: 20, endM: 20)
        let plannedTemplate: [PlannedActivity] = [
            .init(activityName: "Leitura",     duration: 30, slotId: s1.id),
            .init(activityName: "Alongamento", duration: 20, slotId: s2.id),
        ]
        let slotsById: [UUID: TimeRange] = [s1.id: s1.range, s2.id: s2.range]
        
        // Executa (informando fuso do template = UTC)
        let engine = ScheduleEngine()
        let (bucket, replicatedSlots) = engine.buildWeeklySchedule(
            plannedTemplate: plannedTemplate,
            slotsById: slotsById,
            startDate: weekStart,
            endDate: weekEnd,
            daysToPlan: 4,
            allowedWeekdays: nil,
            excludedDays: [],
            calendar: cal,
            timeZone: cal.timeZone,
            templateTimeZone: TimeZone(secondsFromGMT: 0)!
        )
        
        // PRINT: semana inteira (Seg→Dom), marcando PULADO
        print("\n--- PreservesTimesAndDurations (SEMANA ATUAL: Seg → Dom) ---")
        for day in allWeekDays {
            if let acts = bucket[day] {
                print(fmtDay(day, cal: cal))
                for a in acts { print(fmtActivity(a, slotsById: replicatedSlots, cal: cal)) }
            } else {
                print("\(fmtDay(day, cal: cal))  >> PULADO")
            }
        }
        
        // ===== ASSERTS ENXUTOS =====
        
        // 1) Deve replicar em pelo menos um dia e todos dentro da semana
        XCTAssertFalse(bucket.isEmpty, "Deve replicar pelo menos um dia.")
        XCTAssertTrue(bucket.keys.allSatisfy { $0 >= weekStart && $0 < weekEnd }, "Dia fora da semana atual.")
        
        // 2) Em cada dia replicado, deve haver exatamente as duas atividades do template,
        //    com o mesmo "wall-clock" e duração.
        let expected: [String: (h: Int, m: Int, dur: Int)] = [
            "Leitura":     (18, 30, 30),
            "Alongamento": (20,  0, 20),
        ]
        
        for acts in bucket.values {
            XCTAssertEqual(acts.count, 2, "Cada dia replicado deve ter 2 atividades do template.")
            
            for a in acts {
                guard let tr = replicatedSlots[a.slotId] else {
                    return XCTFail("Slot não encontrado para \(a.activityName)")
                }
                let comps = cal.dateComponents([.hour, .minute], from: tr.start)
                let durMin = Int(tr.end.timeIntervalSince(tr.start) / 60)
                
                guard let exp = expected[a.activityName] else {
                    XCTFail("Atividade inesperada: \(a.activityName)")
                    continue
                }
                XCTAssertEqual(comps.hour,   exp.h,   "Hora inválida em \(a.activityName)")
                XCTAssertEqual(comps.minute, exp.m,   "Minuto inválido em \(a.activityName)")
                XCTAssertEqual(durMin,       exp.dur, "Duração inválida em \(a.activityName)")
                XCTAssertEqual(a.duration,   exp.dur, "Duration do PlannedActivity deve bater com o slot.")
            }
        }
    }
    
    func test_BuildWeeklySchedule_ExcludedDaysAreSkipped() {
        // DESTINO: America/Fortaleza (datas atuais)
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "pt_BR")
        cal.timeZone = TimeZone(identifier: "America/Fortaleza")!

        // Semana atual: segunda 00:00 → próxima segunda 00:00 (exclusiva)
        let todayStart = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: todayStart) // 1=dom ... 7=sáb
        let daysSinceMonday = (weekday - 2 + 7) % 7
        let weekStart = cal.date(byAdding: .day, value: -daysSinceMonday, to: todayStart)!
        let weekEnd   = cal.date(byAdding: .day, value: 7, to: weekStart)!
        let allWeekDays: [Date] = (0..<7).map { cal.startOfDay(for: cal.date(byAdding: .day, value: $0, to: weekStart)!) }

        // Vamos excluir a QUARTA (2 dias após a segunda)
        let excludedDay = cal.date(byAdding: .day, value: 2, to: weekStart)!
        let excludedKey = cal.startOfDay(for: excludedDay)

        // Template em UTC (helpers) — uma atividade simples
        let s1 = makeSlot(weekStart, startH: 18, startM: 30, endH: 19, endM: 0)
        let plannedTemplate: [PlannedActivity] = [
            .init(activityName: "Leitura", duration: 30, slotId: s1.id)
        ]
        let slotsById: [UUID: TimeRange] = [s1.id: s1.range]

        let engine = ScheduleEngine()

        // ===== CENÁRIO A: 3 DIAS, .auto (deve REMANEJAR e manter 3 dias) =====
        do {
            let (bucket, replicatedSlots) = engine.buildWeeklySchedule(
                plannedTemplate: plannedTemplate,
                slotsById: slotsById,
                startDate: weekStart,
                endDate: weekEnd,
                daysToPlan: 3,
                allowedWeekdays: nil,
                excludedDays: [excludedDay],
                calendar: cal,
                timeZone: cal.timeZone,
                templateTimeZone: TimeZone(secondsFromGMT: 0)!, // helpers em UTC
                excludedHandling: .auto
            )

            print("\n--- ExcludedDaysAreSkipped [A: 3 dias, .auto → REMANEJA] ---")
            for day in allWeekDays {
                if let acts = bucket[day] {
                    print(fmtDay(day, cal: cal))
                    for a in acts { print(fmtActivity(a, slotsById: replicatedSlots, cal: cal)) }
                } else {
                    print("\(fmtDay(day, cal: cal))  >> PULADO")
                }
            }

            // Excluído não pode aparecer
            XCTAssertNil(bucket[excludedKey], "Dia excluído não deve estar no bucket (A).")
            // Deve manter exatamente 3 dias (remanejamento obrigatório quando daysToPlan=3)
            XCTAssertEqual(bucket.keys.count, 3, "Com 3 dias, deve remanejar para manter 3 (A).")
            // Tudo dentro da janela
            XCTAssertTrue(bucket.keys.allSatisfy { $0 >= weekStart && $0 < weekEnd }, "Dia fora da semana atual (A).")
        }

        // ===== CENÁRIO B: 5 DIAS, .drop (pode apenas excluir, sem repor) =====
        do {
            let (bucket, replicatedSlots) = engine.buildWeeklySchedule(
                plannedTemplate: plannedTemplate,
                slotsById: slotsById,
                startDate: weekStart,
                endDate: weekEnd,
                daysToPlan: 5,
                allowedWeekdays: nil,
                excludedDays: [excludedDay],
                calendar: cal,
                timeZone: cal.timeZone,
                templateTimeZone: TimeZone(secondsFromGMT: 0)!, // helpers em UTC
                excludedHandling: .drop
            )

            print("\n--- ExcludedDaysAreSkipped [B: 5 dias, .drop → pode só excluir] ---")
            for day in allWeekDays {
                if let acts = bucket[day] {
                    print(fmtDay(day, cal: cal))
                    for a in acts { print(fmtActivity(a, slotsById: replicatedSlots, cal: cal)) }
                } else {
                    print("\(fmtDay(day, cal: cal))  >> PULADO")
                }
            }

            // Excluído não pode aparecer
            XCTAssertNil(bucket[excludedKey], "Dia excluído não deve estar no bucket (B).")
            // Pode ficar com <= 5 (não repõe). Ainda assim, mínimo da engine é 3.
            XCTAssertGreaterThanOrEqual(bucket.keys.count, 3, "Deve haver ao menos 3 dias (B).")
            XCTAssertLessThanOrEqual(bucket.keys.count, 5, "Não deve exceder 5 dias (B).")
            // Tudo dentro da janela
            XCTAssertTrue(bucket.keys.allSatisfy { $0 >= weekStart && $0 < weekEnd }, "Dia fora da semana atual (B).")
        }
    }

}
