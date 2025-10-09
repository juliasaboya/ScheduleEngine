//
//  Contractes.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 03/10/25.
//

import Foundation

// MARK: - Repository Protocol

public protocol ActivityRepositoryProtocol<ActivityType> {
    associatedtype ActivityType: ActivityProtocol
    func catalog() -> [ActivityType]
}

