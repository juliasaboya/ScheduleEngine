//
//  ActivityRepositoryProtocol.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 03/10/25.
//

import Foundation

protocol ActivityRepositoryProtocol {
    func fetchAllActivities() -> [Activity]
}


class ActivityRepositoryIMPL: ActivityRepositoryProtocol {
    func fetchAllActivities() -> [Activity] {
        return MockData.activities
    }
}
