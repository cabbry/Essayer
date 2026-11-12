import Foundation

/// Les scènes photographiées pour l'App Store par le workflow
/// `screenshots.yml` : l'appli est lancée avec `-screenshot <nom>`, se place à
/// une date de la saison voulue et remplit un carnet d'essais fictif.
/// Le mode n'existe qu'en Debug : il est absent des builds TestFlight.
struct ScreenshotScene {
    let date: Date
    let attempts: Int
    let triedToday: Bool
    let showsHistory: Bool

    static let current: ScreenshotScene? = {
        #if DEBUG
        guard let name = UserDefaults.standard.string(forKey: "screenshot") else { return nil }
        return scenes[name]
        #else
        return nil
        #endif
    }()

    private static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.gregorian.date(from: DateComponents(year: year, month: month, day: day, hour: 10)) ?? .now
    }

    private static let scenes: [String: ScreenshotScene] = [
        "spring": ScreenshotScene(date: day(2027, 4, 28), attempts: 30, triedToday: false, showsHistory: false),
        "summer": ScreenshotScene(date: day(2027, 7, 25), attempts: 24, triedToday: true, showsHistory: false),
        "autumn": ScreenshotScene(date: day(2026, 10, 30), attempts: 18, triedToday: false, showsHistory: false),
        "winter": ScreenshotScene(date: day(2027, 1, 20), attempts: 12, triedToday: true, showsHistory: false),
        "history": ScreenshotScene(date: day(2027, 4, 28), attempts: 30, triedToday: true, showsHistory: true),
    ]

    /// Un carnet fictif : les derniers jours de la saison avant `date` sont
    /// tous essayés, et aujourd'hui aussi si `triedToday`.
    func makeStore() -> AttemptStore {
        let suite = "screenshots"
        UserDefaults.standard.removePersistentDomain(forName: suite)
        let store = AttemptStore(defaults: UserDefaults(suiteName: suite) ?? .standard)

        let calendar = Calendar.gregorian
        let start = Season.start(of: date, calendar: calendar)
        let today = calendar.startOfDay(for: date)
        let daysBefore = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        let past = min(triedToday ? attempts - 1 : attempts, daysBefore)

        for index in 0..<max(past, 0) {
            guard let day = calendar.date(byAdding: .day, value: daysBefore - past + index, to: start) else { continue }
            let noon = day.addingTimeInterval(12 * 3600)
            store.attempt(Challenges.forDay(noon, calendar: calendar), on: noon)
        }
        if triedToday {
            store.attempt(Challenges.forDay(date, calendar: calendar), on: date)
        }
        return store
    }
}
