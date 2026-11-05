import Foundation
import UserNotifications

/// Deux notifications par jour, réglables dans l'écran Réglages : le défi du
/// jour le matin, puis une relance en fin d'après-midi si ce n'est pas fait.
/// La relance porte deux boutons : « J'ai essayé » et « Pas pour moi ».
///
/// Le texte change tous les jours : on programme donc les notifications jour
/// par jour pour les semaines à venir, et on recommence à chaque ouverture de
/// l'appli ou changement de réglage. Le jour où l'essai est fait, on ne
/// dérange plus.
enum DailyReminder {
    static let eveningCategory = "EVENING_CHECKIN"
    static let triedAction = "TRIED"
    static let dislikeAction = "DISLIKE"
    static let challengeKey = "challenge"

    /// iOS garde au plus 64 notifications en attente : 2 par jour sur 30 jours.
    private static let daysAhead = 30
    private static let identifierPrefix = "daily-challenge-"

    static func registerCategories() {
        let tried = UNNotificationAction(identifier: triedAction, title: tr("J'ai essayé", "I tried"), options: [])
        let dislike = UNNotificationAction(identifier: dislikeAction, title: tr("Pas pour moi", "Not for me"), options: [.foreground])
        let evening = UNNotificationCategory(identifier: eveningCategory, actions: [tried, dislike],
                                             intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([evening])
    }

    static func refresh(alreadyTriedToday: Bool, calendar: Calendar = .current) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let previous = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: previous)

        let morning = ReminderSettings.morningEnabled
        let evening = ReminderSettings.eveningEnabled
        guard morning || evening else { return }

        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else { return }

        let now = Date.now
        let today = calendar.startOfDay(for: now)
        for offset in 0..<daysAhead {
            if offset == 0 && alreadyTriedToday { continue }
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let challenge = Challenges.forDay(day, calendar: calendar)

            if morning {
                await schedule(on: day, minutes: ReminderSettings.morningMinutes, title: tr("Le défi du jour", "Today's challenge"),
                               body: Challenges.localized(challenge), category: nil, challenge: challenge,
                               now: now, center: center, calendar: calendar)
            }
            if evening {
                await schedule(on: day, minutes: ReminderSettings.eveningMinutes, title: tr("Alors, tu as essayé ?", "So, did you try?"),
                               body: Challenges.localized(challenge), category: eveningCategory, challenge: challenge,
                               now: now, center: center, calendar: calendar)
            }
        }
    }

    private static func schedule(on day: Date, minutes: Int, title: String, body: String, category: String?,
                                 challenge: String, now: Date,
                                 center: UNUserNotificationCenter, calendar: Calendar) async {
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = minutes / 60
        components.minute = minutes % 60
        guard let fireDate = calendar.date(from: components), fireDate > now else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = [challengeKey: challenge]
        if let category { content.categoryIdentifier = category }

        let identifier = identifierPrefix
            + "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)-\(minutes)"
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }
}
