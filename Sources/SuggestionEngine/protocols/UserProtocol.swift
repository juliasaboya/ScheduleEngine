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
    var intensity: Intensity { get }
    var locations: [LocationType] { get }
    var activitiesIDs: [UUID] { get }
}
