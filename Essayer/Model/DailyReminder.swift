import Foundation
import UserNotifications

/// Deux notifications par jour : le défi du jour le matin, puis une relance
/// en fin d'après-midi pour demander si c'est fait.
///
/// Le texte change tous les jours : on programme donc les notifications jour
/// par jour pour les semaines à venir, et on recommence à chaque ouverture de
/// l'appli. Le jour où l'essai est déjà fait, on ne dérange plus.
enum DailyReminder {
    static let morningHour = 9
    static let eveningHour = 17
    /// iOS garde au plus 64 notifications en attente : 2 par jour sur 30 jours.
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
            let challenge = Challenges.forDay(day, calendar: calendar)

            await schedule(on: day, hour: morningHour, title: "Le défi du jour",
                           body: challenge, now: now, center: center, calendar: calendar)
            await schedule(on: day, hour: eveningHour, title: "Alors, tu as essayé ?",
                           body: "Il est encore temps : \(challenge)", now: now, center: center, calendar: calendar)
        }
    }

    private static func schedule(on day: Date, hour: Int, title: String, body: String, now: Date,
                                 center: UNUserNotificationCenter, calendar: Calendar) async {
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = hour
        guard let fireDate = calendar.date(from: components), fireDate > now else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let identifier = identifierPrefix
            + "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)-\(hour)"
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }
}
