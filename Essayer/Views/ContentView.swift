import SwiftUI

struct ContentView: View {
    @Environment(AttemptStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    @State private var today = Date.now
    @State private var progress: Double = 0
    @State private var burstDate: Date?
    /// Permet de voir les autres saisons en touchant le kanji, sans attendre.
    @State private var previewSeason: Season?
    /// Appui long sur le titre : montre l'arbre au maximum de la saison.
    @State private var previewsFullGrowth = false
    @State private var showsHistory = false

    private var realSeason: Season { Season(date: today) }
    private var season: Season { previewSeason ?? realSeason }
    private var challenge: String { Challenges.forDay(today) }
    private var triedToday: Bool { store.hasAttempted(on: today) }
    private var seasonAttempts: Int { store.attempts(inSeasonOf: today).count }

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
        .onAppear { progress = Double(seasonAttempts) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { today = .now }
        }
        // Une nouvelle saison commence : l'arbre repart de zéro.
        .onChange(of: Season.start(of: today)) {
            previewsFullGrowth = false
            syncProgress()
        }
        .task(id: "\(triedToday)-\(Calendar.current.startOfDay(for: today))") {
            await DailyReminder.refresh(alreadyTriedToday: triedToday)
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
                    .onLongPressGesture(perform: toggleFullGrowthPreview)
                    .accessibilityHint("Appui long pour voir l'arbre au maximum de la saison.")
                Text(previewsFullGrowth ? "Aperçu : l'arbre au bout de 30 essais" : attemptsLabel)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(previewsFullGrowth ? Color.vermilion : Color.ink.opacity(0.6))
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
        let count = seasonAttempts
        let goal = Int(TreeModel.fullGrowthAttempts)
        return switch count {
        case 0: "Ton arbre attend ton premier essai \(realSeason.thisSeason)"
        case 1: "1 essai \(realSeason.thisSeason)"
        case goal...: "\(count) essais \(realSeason.thisSeason) : arbre en pleine forme"
        default: "\(count) essais \(realSeason.thisSeason) sur \(goal)"
        }
    }

    private func attempt() {
        let now = Date.now
        withAnimation(.easeInOut(duration: 0.4)) {
            store.attempt(challenge, on: now)
        }
        burstDate = now
        previewsFullGrowth = false
        syncProgress(duration: 2.2)
    }

    private func syncProgress(duration: Double = 1.6) {
        let target = previewsFullGrowth ? TreeModel.fullGrowthAttempts : Double(seasonAttempts)
        withAnimation(.easeInOut(duration: duration)) {
            progress = target
        }
    }

    private func toggleFullGrowthPreview() {
        previewsFullGrowth.toggle()
        syncProgress()
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
