import Foundation
import Observation

/// Garde la liste des essais sur l'appareil. L'arbre ne fait que grandir :
/// on ajoute des essais, on n'en retire jamais.
@Observable
final class AttemptStore {
    /// Le carnet de l'appli, partagé avec les boutons des notifications.
    static let shared = AttemptStore()

    private(set) var attempts: [Attempt] = []

    @ObservationIgnored private let defaults: UserDefaults
    private static let storageKey = "attempts.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([Attempt].self, from: data) {
            attempts = saved
        }
    }

    func hasAttempted(on day: Date, calendar: Calendar = .current) -> Bool {
        attempts.contains { calendar.isDate($0.date, inSameDayAs: day) }
    }

    /// Les essais de la saison en cours : ce sont eux qui font pousser l'arbre.
    func attempts(inSeasonOf day: Date, calendar: Calendar = .current) -> [Attempt] {
        let start = Season.start(of: day, calendar: calendar)
        return attempts.filter { $0.date >= start }
    }

    /// Un seul essai par jour : le défi du jour.
    func attempt(_ challenge: String, on day: Date = .now) {
        guard !hasAttempted(on: day) else { return }
        attempts.append(Attempt(date: day, challenge: challenge))
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(attempts) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
