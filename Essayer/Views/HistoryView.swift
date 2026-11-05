import SwiftUI

/// La liste de tous les essais, du plus récent au plus ancien.
struct HistoryView: View {
    @Environment(AttemptStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.attempts.isEmpty {
                    ContentUnavailableView(
                        tr("Pas encore d'essai", "No tries yet"),
                        systemImage: "leaf",
                        description: Text(tr("Chaque essai fera fleurir ton arbre.", "Every try will make your tree bloom."))
                    )
                } else {
                    List(Array(store.attempts.reversed())) { attempt in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(attempt.date, format: .dateTime.weekday(.wide).day().month(.wide).year())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(Challenges.localized(attempt.challenge))
                                .font(.system(.body, design: .serif))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(tr("Mes essais", "My tries"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr("Fermer", "Close")) { dismiss() }
                }
            }
        }
    }
}
