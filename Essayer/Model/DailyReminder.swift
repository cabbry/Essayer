import Foundation
import UserNotifications

/// Une notification chaque matin avec le défi du jour.
///
/// Le texte change tous les jours : on programme donc une notification par
/// jour pour les semaines à venir, et on recommence à chaque ouverture de
/// l'appli. Le jour où l'essai est déjà fait, on ne dérange pas.
enum DailyReminder {
    static let hour = 9
    private static let daysAhead = 30
    private static let identifierPrefix = "daily-challenge-"

    static func refresh(alreadyTriedToday: Bool, calendar: Calendar = .current) async {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else { return }

        let pending = await center.pendingNotificationRequests()
        let previous = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: previous)

        let now = Date.now
        let today = calendar.startOfDay(for: now)
        for offset in 0..<daysAhead {
            if offset == 0 && alreadyTriedToday { continue }
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = hour
            guard let fireDate = calendar.date(from: components), fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Le défi du jour"
            content.body = Challenges.forDay(day, calendar: calendar)
            content.sound = .default

            let identifier = identifierPrefix + "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
        }
    }
}
