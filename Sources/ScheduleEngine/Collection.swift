//
//  Collection.swift
//  ScheduleEngine
//
//  Created by Júlia Saboya on 17/09/25.
//
import Foundation

public extension Collection {
    func maxBy<T: Comparable>(_ score: (Element) -> T) -> Element? {
        self.max(by: { score($0) < score($1) })
    }
}
