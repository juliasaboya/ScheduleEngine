//
//  DemoGoal.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 18/09/25.
//


import Foundation
import ScheduleEngine

// MARK: - Demo

@main
struct Main {
  static func main() {
    let engine = ScheduleEngine()

    // Exemplo do teu enunciado: 20/09/2025 com 3 slots
    let Y = 2025, M = 9, D = 20
    let slots: [DemoSlot] = [
      slot(Y, M, D, 7, 30, 8, 0),   // 30 min
      slot(Y, M, D, 13, 0, 13, 30), // 30 min
      slot(Y, M, D, 20, 0, 21, 0),  // 60 min
    ]

    // Lista de atividades com goals associados
    let activities: [DemoActivity] = [
      .init(name: "caminhada leve",        minDuration: 15, maxDuration: 60, goals: [.loseWeight]),
      .init(name: "corrida",               minDuration: 20, maxDuration: 40, goals: [.loseWeight]),
      .init(name: "polichinelos",          minDuration: 10, maxDuration: 20, goals: [.loseWeight]),
      .init(name: "abdominais",            minDuration: 10, maxDuration: 20, goals: [.quitSedentarism]),
      .init(name: "musculação superiores", minDuration: 20, maxDuration: 60, goals: [.gainWeight]),
    ]

    do {
      let plan = try engine.generateDailySchedule(
        day: date(Y, M, D, 0, 0),
        slots: slots,
        userGoals: Set<DemoGoal>([.loseWeight]),
        userList: activities,
        options: .init(dailyMinimumMinutes: 50, avoidConsecutiveRepeat: true)
      )

      // Índice rápido de slot por id pra imprimir o horário certinho
      let slotById = Dictionary(uniqueKeysWithValues: slots.map { ($0.id, $0) })

      print("Cronograma de \(String(format: "%02d/%02d/%04d", D, M, Y))\n")
      var total = 0
      for item in plan {
        guard let s = slotById[item.slotId] else { continue }
        print("[\(fmtRange(s.range))] -> \(item.activityName) (\(item.duration) min)")
        total += item.duration
      }
      print("\nTotal do dia: \(total) min \(total >= 50 ? "✅" : "⚠️")")

    } catch {
      fputs("Erro ao gerar cronograma: \(error)\n", stderr)
      exit(1)
    }
  }
}
