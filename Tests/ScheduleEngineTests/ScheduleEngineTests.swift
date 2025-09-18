import XCTest
@testable import ScheduleEngine

final class ScheduleEngineTests: XCTestCase {

    func test_PlanActivities_Until_Minimum_Is_Met() throws {
        let day = makeDate(Date(timeIntervalSince1970: 0), hour: 0, minute: 0)
        let slots: [TestSlot] = [
            makeSlot(day, startH: 7, startM: 30, endH: 8, endM: 0),
            makeSlot(day, startH: 13, startM: 0, endH: 13, endM: 30),
            makeSlot(day, startH: 20, startM: 0, endH: 21, endM: 0),
        ]
        let activities: [TestActivity] = [
            .init(name: "caminhada leve",       minDuration: 15, maxDuration: 60, goals: [.loseWeight]),
            .init(name: "corrida",              minDuration: 20, maxDuration: 40, goals: [.loseWeight]),
            .init(name: "polichinelos",         minDuration: 10, maxDuration: 20, goals: [.loseWeight]),
            .init(name: "abdominais",           minDuration: 10, maxDuration: 20, goals: [.quitSedentarism]),
            .init(name: "musculação superiores",minDuration: 20, maxDuration: 60, goals: [.gainWeight]),
        ]
    }

    func test_FillsAllSlots_And_MeetsDailyMinimum_WhenPossible() throws {
        let day = makeDate(Date(timeIntervalSince1970: 0), hour: 0, minute: 0) 
        let slots: [TestSlot] = [
            makeSlot(day, startH: 7, startM: 30, endH: 8, endM: 0),
            makeSlot(day, startH: 13, startM: 0, endH: 13, endM: 30),
            makeSlot(day, startH: 20, startM: 0, endH: 21, endM: 0),
        ]
        let slotMinutes = slots.map { minutes($0.range) }

        let activities: [TestActivity] = [
            .init(name: "caminhada leve",       minDuration: 15, maxDuration: 60, goals: [.loseWeight]),
            .init(name: "corrida",              minDuration: 20, maxDuration: 40, goals: [.loseWeight]),
            .init(name: "polichinelos",         minDuration: 10, maxDuration: 20, goals: [.loseWeight]),
            .init(name: "abdominais",           minDuration: 10, maxDuration: 20, goals: [.quitSedentarism]),
            .init(name: "musculação superiores",minDuration: 20, maxDuration: 60, goals: [.gainWeight]),
        ]
        let byName = Dictionary(uniqueKeysWithValues: activities.map { ($0.name, $0) })

        let engine = ScheduleEngine()
        let plan = try engine.generateDailySchedule(
            day: day,
            slots: slots,
            userGoals: Set<TestGoal>([.loseWeight]),
            userList: activities,
            options: .init(dailyMinimumMinutes: 50, avoidConsecutiveRepeat: true)
        )

        XCTAssertEqual(plan.count, slots.count, "Deveria haver um item planejado para cada slot.")

        for (idx, item) in plan.enumerated() {
            let slotMax = slotMinutes[idx]
            XCTAssertLessThanOrEqual(item.duration, slotMax, "Duração não pode exceder o tamanho do slot.")

            guard let act = byName[item.activityName] else {
                XCTFail("Atividade \(item.activityName) não encontrada no catálogo.")
                continue
            }
            XCTAssertGreaterThanOrEqual(item.duration, act.minDuration, "Deve respeitar minDuration da atividade.")
            XCTAssertLessThanOrEqual(item.duration, act.maxDuration, "Deve respeitar maxDuration da atividade.")
        }
    }
}
