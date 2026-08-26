// Role: day key as Int epoch seconds at startOfDay in the user's calendar.

import Foundation

enum VaultDayClock {
    static func dayKey(for date: Date, calendar: Calendar = .current) -> Int {
        Int(calendar.startOfDay(for: date).timeIntervalSince1970)
    }

    static func date(from dayKey: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(dayKey))
    }

    static func nextDayKey(after dayKey: Int, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date(from: dayKey))
        let next = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        return Int(calendar.startOfDay(for: next).timeIntervalSince1970)
    }

    static func isFuture(_ dayKey: Int, now: Date = Date(), calendar: Calendar = .current) -> Bool {
        dayKey > self.dayKey(for: now, calendar: calendar)
    }

    static func shift(_ dayKey: Int, days: Int, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date(from: dayKey))
        let moved = calendar.date(byAdding: .day, value: days, to: start) ?? start
        return Int(calendar.startOfDay(for: moved).timeIntervalSince1970)
    }
}
