//
//  UserProtocol.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

public protocol UserProtocol {
    var availableTime: Int { get }
    var goals: [Goal] { get }
    var locations: [LocationType] { get }
    var activitiesIDs: [UUID] { get }
}
