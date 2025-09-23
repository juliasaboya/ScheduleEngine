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
        let Y = 2025, M = 9, D = 20

        let slots: [DemoSlot] = [
            slot(Y, M, D, 7, 30, 8, 0),   // 30 min
            slot(Y, M, D, 13, 0, 13, 30), // 30 min
            slot(Y, M, D, 19, 0, 20, 30), // 30 min
            slot(Y, M, D, 15, 0, 16, 30), // 30 min


        ]

        let activities: [DemoActivity] = [
            .init(goals: [.loseWeight], name: "caminhada leve", minDuration: 15, maxDuration: 20),
            .init(goals: [.loseWeight], name: "corrida",        minDuration: 15, maxDuration: 20),
            .init(goals: [.loseWeight], name: "polichinelos",   minDuration: 5, maxDuration: 10),
            .init(goals: [.quitSedentarism], name: "abdominais", minDuration: 5, maxDuration: 10),
            .init(goals: [.gainWeight], name: "musculação sup.", minDuration: 15, maxDuration: 50),
            .init(goals: [.gainWeight, .loseWeight, .quitSedentarism], name: "alongamento completo", minDuration: 3, maxDuration: 15),

        ]

        do {

            let plan = try engine.generateDailySchedule(
                day: Date(),
                slots: slots,
                userGoals: [.loseWeight],
                userList: activities
            )

            let slotById = Dictionary(uniqueKeysWithValues: slots.map { ($0.id, $0) })

            print("Cronograma de \(String(format: "%02d/%02d/%04d", D, M, Y))\n")
            var total = 0

            for item in plan {
                guard let s = slotById[item.slotId] else { continue }
                print("[\(fmtRange(s.range))] -> \(item.activityName) (\(item.duration) min)")
                total += item.duration
            }

            print("\nTotal do dia: \(total) min \(total >= 30 && total <= 50 ? "✅" : "⚠️")")

        } catch {
            fputs("Erro ao gerar cronograma: \(error)\n", stderr)
            exit(1)
        }
    }
}
