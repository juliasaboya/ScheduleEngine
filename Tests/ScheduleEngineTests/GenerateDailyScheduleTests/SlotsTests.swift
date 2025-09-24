//
//  ScheduleEngineTests.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 22/09/25.
//
import XCTest
@testable import ScheduleEngine

final class SlotsTests: XCTestCase {
    let engine = ScheduleEngine()
    let day = makeDate(Date(timeIntervalSince1970: 0), hour: 0, minute: 0)
    let activities: [TestActivity] = [
        .init(goals: [.loseWeight], locations: [.home], name: "caminhada leve",       minDuration: 15, maxDuration: 60),
        .init(goals: [.loseWeight], locations: [.home], name: "corrida",              minDuration: 20, maxDuration: 40),
        .init(goals: [.loseWeight], locations: [.home], name: "polichinelos",         minDuration: 10, maxDuration: 20),
        .init(goals: [.quitSedentarism], locations: [.home], name: "abdominais",           minDuration: 10, maxDuration: 20),
        .init(goals: [.gainWeight], locations: [.home], name: "musculação superiores",minDuration: 20, maxDuration: 60),
    ]
    func test_If_Minimum_Is_Met_With_1Slot() throws {
        let slots: [TestSlot] = [
            makeSlot(day, startH: 7, startM: 30, endH: 8, endM: 0), // 30 min
        ]

        let plan = try engine.generateDailySchedule(
            day: day,
            slots: slots,
            userGoals: Set<TestGoal>([.loseWeight]), possibleLocations: Set<TestLocationType>([.gym]),
            userList: activities
        )
        var total = 0
        for item in plan {
            total += item.plannedMinutes
        }

        XCTAssertGreaterThanOrEqual(total, 30)
    }

    func test_If_Minimum_Is_Met_With_2Slots() throws {
        let slots: [TestSlot] = [
            makeSlot(day, startH: 7, startM: 30, endH: 7, endM: 45), // 15 min
            makeSlot(day, startH: 13, startM: 30, endH: 13, endM: 45), // 15 min

        ]

        let plan = try engine.generateDailySchedule(
            day: day,
            slots: slots,
            userGoals: Set<TestGoal>([.loseWeight]), possibleLocations: Set<TestLocationType>([.home]),
            userList: activities
        )
        var total = 0
        for item in plan {
            total += item.plannedMinutes
        }

        XCTAssertGreaterThanOrEqual(total, 30)
    }

    func test_If_Minimum_Is_Met_With_3Slots() throws {
        let slots: [TestSlot] = [
            makeSlot(day, startH: 7, startM: 30, endH: 7, endM: 40), // 10 min
            makeSlot(day, startH: 13, startM: 30, endH: 13, endM: 40), // 10 min
            makeSlot(day, startH: 19, startM: 30, endH: 19, endM: 40), // 10 min
        ]

        let plan = try engine.generateDailySchedule(
            day: day,
            slots: slots,
            userGoals: Set<TestGoal>([.loseWeight]), possibleLocations: Set<TestLocationType>([.home]),
            userList: activities
        )
        var total = 0
        for item in plan {
            total += item.plannedMinutes
        }

        XCTAssertGreaterThanOrEqual(total, 30)

    }

    func test_If_Throws_When_totalMinutes_Not_Enough() throws {
        let slots: [TestSlot] = [
            makeSlot(day, startH: 7, startM: 30, endH: 7, endM: 40),
            makeSlot(day, startH: 8, startM: 30, endH: 8, endM: 10),

        ]

        XCTAssertThrowsError(
            try engine.generateDailySchedule(
                day: day,
                slots: slots,
                userGoals: [.loseWeight],possibleLocations: Set<TestLocationType>([.home]),
                userList: activities
            )

        ){ error in
            guard let engErr = error as? ScheduleEngineError else {
                return XCTFail("Erro inesperado: \(error)")
            }
            switch engErr {
            case .slotsMinutesNotEnough:
                break 
            default:
                XCTFail("Esperava slotsMinutesNotEnough, recebi \(engErr)")
            }
        }
    }
}
