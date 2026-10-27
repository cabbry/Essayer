import CloudKit
import Foundation

/// Ce que tous les utilisateurs partagent, dans la base publique CloudKit
/// d'Apple (aucun serveur à nous) : combien de personnes ont essayé le défi
/// du jour, les « Pas pour moi », et les défis retirés à distance.
///
/// Tout est anonyme : seuls le jour, le défi et la réponse sont envoyés.
/// Sans compte iCloud, rien n'est envoyé et l'appli marche normalement.
enum Community {
    static let containerIdentifier = "iCloud.com.cabbry.essayer"
    /// En dessous de ce nombre, le compteur du jour n'est pas affiché.
    static let visibleCountThreshold = 10
    private static let countLimit = 5000

    private static var isEnabled: Bool { ScreenshotScene.current == nil }
    private static var container: CKContainer { CKContainer(identifier: containerIdentifier) }
    private static var database: CKDatabase { container.publicCloudDatabase }

    /// Le jour sous la forme « 2026-10-27 », identique pour tout le monde.
    static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private static func canWrite() async -> Bool {
        guard isEnabled else { return false }
        return (try? await container.accountStatus()) == .available
    }

    static func recordAttempt(challenge: String, on day: Date) async {
        guard await canWrite() else { return }
        let record = CKRecord(recordType: "Attempt")
        record["day"] = dayKey(day)
        record["challenge"] = challenge
        _ = try? await database.save(record)
    }

    static func recordDislike(challenge: String, on day: Date, reason: String) async {
        guard await canWrite() else { return }
        let record = CKRecord(recordType: "Dislike")
        record["day"] = dayKey(day)
        record["challenge"] = challenge
        record["reason"] = reason
        _ = try? await database.save(record)
    }

    /// Combien de personnes ont essayé le défi de ce jour (plafonné à 5 000).
    static func attemptCount(on day: Date) async -> Int? {
        guard isEnabled else { return nil }
        let query = CKQuery(recordType: "Attempt", predicate: NSPredicate(format: "day == %@", dayKey(day)))
        do {
            var page = try await database.records(matching: query, desiredKeys: [])
            var count = page.matchResults.count
            while let cursor = page.queryCursor, count < countLimit {
                page = try await database.records(continuingMatchFrom: cursor, desiredKeys: [])
                count += page.matchResults.count
            }
            return count
        } catch {
            return nil
        }
    }

    /// Les défis retirés à distance (enregistrements « DisabledChallenge »
    /// créés dans la console CloudKit), gardés sur l'appareil.
    static func refreshDisabledChallenges() async {
        guard isEnabled else { return }
        let query = CKQuery(recordType: "DisabledChallenge", predicate: NSPredicate(value: true))
        guard let page = try? await database.records(matching: query, desiredKeys: ["challenge"]) else { return }
        let texts = page.matchResults.compactMap { _, result in
            (try? result.get())?["challenge"] as? String
        }
        Challenges.disabled = Set(texts)
    }
}
