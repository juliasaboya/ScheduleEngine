//
//  ActivityProtocl.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

public protocol ActivityProtocol {
    var id: UUID { get }
    var goals: [Goal] { get }
    var intensity: Intensity { get }
    var locations: [Location] { get }
    var minTime: Int { get }
    var maxTime: Int { get }
}
