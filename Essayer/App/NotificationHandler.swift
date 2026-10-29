import Observation
import UIKit
import UserNotifications

/// Ce que l'appli doit montrer après une action venue d'ailleurs, par exemple
/// le bouton « Pas pour moi » d'une notification.
@Observable
final class AppRouter {
    static let shared = AppRouter()
    var showsDislikeOptions = false
}

/// Branche le centre de notifications au lancement de l'appli et répond aux
/// boutons de la relance de fin d'après-midi.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        DailyReminder.registerCategories()
        return true
    }

    /// Affiche aussi les notifications quand l'appli est ouverte.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let info = response.notification.request.content.userInfo
        let challenge = info[DailyReminder.challengeKey] as? String
            ?? Challenges.forDay(response.notification.date)

        switch response.actionIdentifier {
        case DailyReminder.triedAction:
            let now = Date.now
            await MainActor.run { AttemptStore.shared.attempt(challenge, on: now) }
            await Community.recordAttempt(challenge: challenge, on: now)
            await DailyReminder.refresh(alreadyTriedToday: true)
        case DailyReminder.dislikeAction:
            await MainActor.run { AppRouter.shared.showsDislikeOptions = true }
        default:
            break
        }
    }
}
