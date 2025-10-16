//
//  ActivityProtocl.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

public protocol ActivityProtocol {
    var id: String { get }
    var goals: [Goal] { get }
    var intensity: Intensity { get }
    var locations: [LocationType] { get }
    var minTime: Int { get }
    var maxTime: Int { get }
}
