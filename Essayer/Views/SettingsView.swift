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

    private static let privacyURL = URL(string: "https://cabbry.github.io/essayer-site/privacy.html")!
    private static let supportURL = URL(string: "https://cabbry.github.io/essayer-site/#support")!

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Le défi du jour", isOn: $morningEnabled)
                    if morningEnabled {
                        DatePicker("Heure", selection: time($morningMinutes), displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Le matin")
                } footer: {
                    Text("Le défi du jour, pour avoir la journée devant toi.")
                }

                Section {
                    Toggle("Alors, tu as essayé ?", isOn: $eveningEnabled)
                    if eveningEnabled {
                        DatePicker("Heure", selection: time($eveningMinutes), displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("La relance")
                } footer: {
                    Text("Seulement si le défi n'est pas encore fait. Tu peux répondre depuis la notification : « J'ai essayé » ou « Pas pour moi ».")
                }

                Section {
                    Toggle("Partager des statistiques anonymes", isOn: $sharesStatistics)
                } footer: {
                    Text("Le jour, le défi et ta réponse, sans rien qui t'identifie, via iCloud. C'est ce qui permet d'afficher combien de personnes ont essayé et de retirer les défis qui ne plaisent pas.")
                }

                Section {
                    Link("Aide et contact", destination: Self.supportURL)
                    Link("Politique de confidentialité", destination: Self.privacyURL)
                }
            }
            .navigationTitle("Réglages")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
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
