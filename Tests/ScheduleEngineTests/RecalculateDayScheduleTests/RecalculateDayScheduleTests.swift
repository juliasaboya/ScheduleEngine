//
//  RecalculateDayScheduleTests.swift
//  ScheduleEngine
//
//  Created by Vinicius Gabriel on 24/09/25.
//

import XCTest
@testable import ScheduleEngine
final class RecalculateDayScheduleTests: XCTestCase {
    var cal: Calendar!
    var monday: Date!
    var tuesday: Date!
    var namesById: [UUID: String]!

    override func setUp() {
        super.setUp()
        cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Fortaleza")!
        monday = cal.date(from: DateComponents(year: 2025, month: 9, day: 22))!
        tuesday = cal.date(byAdding: .day, value: 1, to: monday)!
        namesById = [
            UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!: "Leitura",
            UUID(uuidString: "11111111-2222-3333-4444-555555555555")!: "Caminhada"
        ]
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    struct MockActivity: SchedulableActivity {
        enum Goal: Hashable { case emagrecer, ganharMassa }
        enum LocationType: Hashable { case casa, academia}
        
        var id = UUID()
        var name: String
        var minDuration: Int
        var maxDuration: Int
        var goals: Set<Goal>
        var locations: Set<LocationType>
    }

    struct mockSlot: ScheduleSlot {
        var id = UUID()
        var range: TimeRange
    }
    
    enum UserGoal: Hashable { case emagrecer }
    enum PossibleLocation: Hashable { case casa }
    
    func makePlannedActivity(activityId: UUID, slotId: UUID, minutes: Int) -> PlannedActivity {
        PlannedActivity(activityId: activityId, slotId: slotId, plannedMinutes: minutes)
    }
    
    func makeSlot(day: Date, startHour: Int, durationMinutes: Int) -> mockSlot {
        let start = cal.date(bySettingHour: startHour, minute: 0, second: 0, of: day)!
        let end = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return mockSlot(id: UUID(), range: TimeRange(start: start, end: end))
    }
    
    func test_recalcSameDay_success() throws {
        // prepara slot e atividade
        let slot = makeSlot(day: monday, startHour: 18, durationMinutes: 30)
        let actId = namesById.keys.first!
        
        let planned = [makePlannedActivity(activityId: actId, slotId: slot.id, minutes: 20)]
        
        let bucket: [Date: [PlannedActivity]] = [monday: planned]
        let slotsByDay: [Date: [mockSlot]] = [monday: [slot]]
        
        let engine = ScheduleEngine()
        let result = try engine.recalcDayActivities(
            dayToRecalc: monday,
            originalPlan: planned,
            currentBucket: bucket,
            slotsByDay: slotsByDay,
            userGoals: [.emagrecer],
            activityLocations: [.casa],
            loadActivities: { _ in
                MockActivity(
                    id: actId,
                    name: "Cardio",
                    minDuration: 10,
                    maxDuration: 30,
                    goals: [.emagrecer],
                    locations: [.casa]
                )},
            options: EngineOptions(dailyMinimumMinutes: 30, dailyMaximumMinutes: 50),
            excludedHandling: .reschedule,
            calendar: cal)
        
        XCTAssertEqual(result[monday]?.count, 1)
        let resolvedName = result[monday]!.first!.activityName(from: namesById)
        XCTAssertEqual(resolvedName, "Leitura")
    }
}
