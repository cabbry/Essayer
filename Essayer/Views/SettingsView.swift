import SwiftUI

/// Les réglages : quelles notifications recevoir et à quelle heure, et le
/// partage des statistiques anonymes. Chaque changement reprogramme les
/// notifications.
struct SettingsView: View {
    @Environment(AttemptStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @AppStorage(ReminderSettings.morningEnabledKey) private var morningEnabled = true
    @AppStorage(ReminderSettings.morningMinutesKey) private var morningMinutes = ReminderSettings.defaultMorningMinutes
    @AppStorage(ReminderSettings.eveningEnabledKey) private var eveningEnabled = true
    @AppStorage(ReminderSettings.eveningMinutesKey) private var eveningMinutes = ReminderSettings.defaultEveningMinutes
    @AppStorage(ReminderSettings.sharesStatisticsKey) private var sharesStatistics = true

    private static let privacyURL = URL(string: tr("https://cabbry.github.io/essayer-site/privacy.html",
                                                   "https://cabbry.github.io/essayer-site/privacy-en.html"))!
    private static let supportURL = URL(string: tr("https://cabbry.github.io/essayer-site/#support",
                                                   "https://cabbry.github.io/essayer-site/en.html#support"))!

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(tr("Le défi du jour", "Today's challenge"), isOn: $morningEnabled)
                    if morningEnabled {
                        DatePicker(tr("Heure", "Time"), selection: time($morningMinutes),
                                   displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text(tr("Le matin", "Morning"))
                } footer: {
                    Text(tr("Le défi du jour, pour avoir la journée devant toi.",
                            "Today's challenge, with the whole day ahead of you."))
                }

                Section {
                    Toggle(tr("Alors, tu as essayé ?", "So, did you try?"), isOn: $eveningEnabled)
                    if eveningEnabled {
                        DatePicker(tr("Heure", "Time"), selection: time($eveningMinutes),
                                   displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text(tr("La relance", "Reminder"))
                } footer: {
                    Text(tr("Seulement si le défi n'est pas encore fait. Tu peux répondre depuis la notification : « J'ai essayé » ou « Pas pour moi ».",
                            "Only if today's challenge isn't done yet. You can answer right from the notification: \"I tried\" or \"Not for me\"."))
                }

                Section {
                    Toggle(tr("Partager des statistiques anonymes", "Share anonymous statistics"), isOn: $sharesStatistics)
                } footer: {
                    Text(tr("Le jour, le défi et ta réponse, sans rien qui t'identifie, via iCloud. C'est ce qui permet d'afficher combien de personnes ont essayé et de retirer les défis qui ne plaisent pas.",
                            "The day, the challenge and your answer, with nothing that identifies you, through iCloud. This is what shows how many people tried and lets us remove challenges people don't like."))
                }

                Section {
                    Link(tr("Aide et contact", "Help and contact"), destination: Self.supportURL)
                    Link(tr("Politique de confidentialité", "Privacy policy"), destination: Self.privacyURL)
                }
            }
            .navigationTitle(tr("Réglages", "Settings"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr("Fermer", "Close")) { dismiss() }
                }
            }
            .task(id: "\(morningEnabled)-\(morningMinutes)-\(eveningEnabled)-\(eveningMinutes)") {
                guard ScreenshotScene.current == nil else { return }
                await DailyReminder.refresh(alreadyTriedToday: store.hasAttempted(on: .now))
            }
        }
    }

    /// Une heure de la journée (pour le DatePicker), stockée en minutes.
    private func time(_ minutes: Binding<Int>) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: minutes.wrappedValue / 60, minute: minutes.wrappedValue % 60,
                                      second: 0, of: .now) ?? .now
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                minutes.wrappedValue = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            }
        )
    }
}
