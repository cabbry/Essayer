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
                        "Pas encore d'essai",
                        systemImage: "leaf",
                        description: Text("Chaque essai fera fleurir ton arbre.")
                    )
                } else {
                    List(Array(store.attempts.reversed())) { attempt in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(attempt.date, format: .dateTime.weekday(.wide).day().month(.wide).year())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(attempt.challenge)
                                .font(.system(.body, design: .serif))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Mes essais")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}
