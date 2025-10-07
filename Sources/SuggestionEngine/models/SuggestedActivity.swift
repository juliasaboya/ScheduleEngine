//
//  SuggestedActivity.swift
//  ScheduleEngine
//
//  Created by Rapha Vidal on 06/10/25.
//
import Foundation

// MARK: - Parameter & Return Types

// O objeto de retorno final: uma atividade com uma duração específica sugerida.
public struct SuggestedActivity<ActivityType: ActivityProtocol> {
    public let activity: ActivityType
    public let suggestedDuration: Int
    
    public init(activity: ActivityType, suggestedDuration: Int) {
        self.activity = activity
        self.suggestedDuration = suggestedDuration
    }
}
