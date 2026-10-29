import Foundation

/// Les réglages de l'écran « Réglages » : quelles notifications recevoir, à
/// quelle heure, et le partage des statistiques anonymes. Les heures sont
/// stockées en minutes depuis minuit.
enum ReminderSettings {
    static let morningEnabledKey = "reminder.morning.enabled"
    static let morningMinutesKey = "reminder.morning.minutes"
    static let eveningEnabledKey = "reminder.evening.enabled"
    static let eveningMinutesKey = "reminder.evening.minutes"
    static let sharesStatisticsKey = "community.sharesStatistics"

    static let defaultMorningMinutes = 9 * 60
    static let defaultEveningMinutes = 17 * 60

    private static var defaults: UserDefaults { .standard }

    static var morningEnabled: Bool { defaults.object(forKey: morningEnabledKey) as? Bool ?? true }
    static var eveningEnabled: Bool { defaults.object(forKey: eveningEnabledKey) as? Bool ?? true }
    static var morningMinutes: Int { defaults.object(forKey: morningMinutesKey) as? Int ?? defaultMorningMinutes }
    static var eveningMinutes: Int { defaults.object(forKey: eveningMinutesKey) as? Int ?? defaultEveningMinutes }
    static var sharesStatistics: Bool { defaults.object(forKey: sharesStatisticsKey) as? Bool ?? true }

    /// « 9 h », « 17 h 30 ».
    static func label(minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        return minute == 0 ? "\(hour) h" : String(format: "%d h %02d", hour, minute)
    }
}
