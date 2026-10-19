import SwiftUI

struct ContentView: View {
    @Environment(AttemptStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    @State private var today = Date.now
    @State private var progress: Double = 0
    @State private var burstDate: Date?
    /// Permet de voir les autres saisons en touchant le kanji, sans attendre.
    @State private var previewSeason: Season?
    @State private var showsHistory = false

    private var realSeason: Season { Season(date: today) }
    private var season: Season { previewSeason ?? realSeason }
    private var challenge: String { Challenges.forDay(today) }
    private var triedToday: Bool { store.hasAttempted(on: today) }

    var body: some View {
        ZStack {
            GardenView(season: season, progress: progress, burstDate: burstDate)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer()
                card
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .foregroundStyle(Color.ink)
        .onAppear { progress = Double(store.attempts.count) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { today = .now }
        }
        .sheet(isPresented: $showsHistory) {
            HistoryView()
                .environment(store)
        }
        .sensoryFeedback(.success, trigger: store.attempts.count)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Essayer")
                    .font(.system(.largeTitle, design: .serif).weight(.semibold))
                Text(attemptsLabel)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.ink.opacity(0.6))
            }

            Spacer()

            Button(action: showNextSeason) {
                VStack(spacing: 0) {
                    Text(season.kanji)
                        .font(.system(size: 26, design: .serif))
                    Text(season.name)
                        .font(.caption2)
                        .foregroundStyle(Color.ink.opacity(0.6))
                    if previewSeason != nil {
                        Text("aperçu")
                            .font(.system(size: 9, design: .serif).italic())
                            .foregroundStyle(Color.vermilion)
                    }
                }
                .frame(minWidth: 56)
            }
            .accessibilityLabel("Saison : \(season.name). Toucher pour voir la suivante.")

            Button {
                showsHistory = true
            } label: {
                Image(systemName: "book.closed")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Mes essais")
        }
        .buttonStyle(.plain)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DÉFI DU JOUR")
                .font(.caption.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(Color.ink.opacity(0.55))

            Text(challenge)
                .font(.system(.title3, design: .serif))
                .fixedSize(horizontal: false, vertical: true)

            if triedToday {
                Label("Tu as essayé aujourd'hui. Reviens demain.", systemImage: "leaf")
                    .font(.system(.body, design: .serif).weight(.medium))
                    .foregroundStyle(Color.vermilion)
                    .padding(.vertical, 6)
                    .transition(.opacity)
            } else {
                Button(action: attempt) {
                    Text("J'ai essayé")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .tint(.vermilion)
            }

            Text("Essayer, c'est déjà réussir.")
                .font(.system(.footnote, design: .serif).italic())
                .foregroundStyle(Color.ink.opacity(0.55))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var attemptsLabel: String {
        switch store.attempts.count {
        case 0: "Ton arbre attend ton premier essai"
        case 1: "1 essai"
        default: "\(store.attempts.count) essais"
        }
    }

    private func attempt() {
        let now = Date.now
        withAnimation(.easeInOut(duration: 0.4)) {
            store.attempt(challenge, on: now)
        }
        burstDate = now
        withAnimation(.easeOut(duration: 2.2)) {
            progress = Double(store.attempts.count)
        }
    }

    private func showNextSeason() {
        let next = season.next
        withAnimation(.easeInOut(duration: 0.8)) {
            previewSeason = next == realSeason ? nil : next
        }
    }
}

#Preview {
    ContentView()
        .environment(AttemptStore(defaults: UserDefaults(suiteName: "preview") ?? .standard))
}
