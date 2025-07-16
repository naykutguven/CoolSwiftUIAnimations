//
//  Date+Extensions.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 16.07.25.
//

import SwiftUI

extension Date {
    static var currentWeek: [Date] {
        let calendar = Calendar.current

        guard let firstWeekday = calendar.dateInterval(of: .weekOfMonth, for: .now)?.start else {
            return []
        }

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: firstWeekday) }
    }

    func isSameDay(as date: Date?) -> Bool {
        guard let date else { return false }
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}
