import SwiftUI

struct ContentView: View {
    @Environment(AttemptStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    @State private var today = ScreenshotScene.current?.date ?? Date.now
    @State private var progress: Double = 0
    @State private var burstDate: Date?
    /// Permet de voir les autres saisons en touchant le kanji, sans attendre.
    @State private var previewSeason: Season?
    /// Appui long sur le titre : montre l'arbre au maximum de la saison.
    @State private var previewsFullGrowth = false
    @State private var showsHistory = ScreenshotScene.current?.showsHistory ?? false
    /// Combien de personnes ont essayé le défi du jour (CloudKit).
    @State private var communityCount: Int?
    /// Les défis retirés à distance : les changer redessine le défi du jour.
    @State private var disabledChallenges = Challenges.disabled
    /// « Pas pour moi » peut aussi venir du bouton de la notification du soir.
    @State private var router = AppRouter.shared
    @State private var showsSettings = false
    /// Le jour où « Pas pour moi » a été envoyé, pour ne le proposer qu'une fois.
    @AppStorage("dislikedDay") private var dislikedDay = ""
    /// Le jour où le défi a été déclaré « Pas applicable » : le défi de
    /// remplacement prend sa place jusqu'au soir.
    @AppStorage(Challenges.replacedDayKey) private var replacedDay = ""

    /// La raison est enregistrée en français dans CloudKit (stable d'une langue
    /// à l'autre), et affichée dans la langue de l'utilisateur.
    private static let notApplicable = "Pas applicable"
    private static let dislikeReasons: [(id: String, label: String)] = [
        (notApplicable, tr("Pas applicable : un autre défi", "Doesn't apply: another challenge")),
        ("Trop difficile", tr("Trop difficile", "Too hard")),
        ("Pas mon truc", tr("Pas mon truc", "Not my thing")),
        ("Mal formulé", tr("Mal formulé", "Badly worded")),
        ("Pas le bon moment", tr("Pas le bon moment", "Bad timing")),
    ]

    private var realSeason: Season { Season(date: today) }
    private var season: Season { previewSeason ?? realSeason }
    private var isReplaced: Bool { replacedDay == Community.dayKey(today) }
    private var challenge: String {
        isReplaced ? Challenges.replacement(forDay: today) : Challenges.forDay(today)
    }
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
            if phase == .active, ScreenshotScene.current == nil { today = .now }
        }
        // Une nouvelle saison commence : l'arbre repart de zéro.
        .onChange(of: Season.start(of: today)) {
            previewsFullGrowth = false
            syncProgress()
        }
        // Un essai enregistré depuis la notification fait aussi pousser l'arbre.
        .onChange(of: seasonAttempts) {
            syncProgress(duration: 2.2)
        }
        .task(id: Community.dayKey(today)) {
            await Community.refreshDisabledChallenges()
            disabledChallenges = Challenges.disabled
            communityCount = await Community.attemptCount(on: today)
        }
        .task(id: "\(triedToday)-\(isReplaced)-\(Community.dayKey(today))-\(disabledChallenges.count)") {
            // Pas de demande d'autorisation par-dessus les captures App Store.
            guard ScreenshotScene.current == nil else { return }
            await DailyReminder.refresh(alreadyTriedToday: triedToday)
        }
        .sheet(isPresented: $showsHistory) {
            HistoryView()
                .environment(store)
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView()
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
                    .accessibilityHint(tr("Appui long pour voir l'arbre au maximum de la saison.", "Long-press to preview the tree at full growth."))
                Text(previewsFullGrowth ? tr("Aperçu : l'arbre au bout de 30 essais", "Preview: the tree after 30 tries") : attemptsLabel)
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
                        Text(tr("aperçu", "preview"))
                            .font(.system(size: 9, design: .serif).italic())
                            .foregroundStyle(Color.vermilion)
                    }
                }
                .frame(minWidth: 56)
            }
            .accessibilityLabel(tr("Saison : \(season.name). Toucher pour voir la suivante.",
                                   "Season: \(season.name). Tap to preview the next one."))

            Button {
                showsHistory = true
            } label: {
                Image(systemName: "book.closed")
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(tr("Mes essais", "My tries"))

            Button {
                showsSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .frame(width: 40, height: 44)
            }
            .accessibilityLabel(tr("Réglages", "Settings"))
        }
        .buttonStyle(.plain)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isReplaced ? tr("DÉFI DE REMPLACEMENT", "REPLACEMENT CHALLENGE") : tr("DÉFI DU JOUR", "TODAY'S CHALLENGE"))
                .font(.caption.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(Color.ink.opacity(0.55))

            Text(Challenges.localized(challenge))
                .font(.system(.title3, design: .serif))
                .fixedSize(horizontal: false, vertical: true)

            if triedToday {
                Label(tr("Tu as essayé aujourd'hui. Reviens demain.", "You tried today. Come back tomorrow."), systemImage: "leaf")
                    .font(.system(.body, design: .serif).weight(.medium))
                    .foregroundStyle(Color.vermilion)
                    .padding(.vertical, 6)
                    .transition(.opacity)
            } else {
                Button(action: attempt) {
                    Text(tr("J'ai essayé", "I tried"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .tint(.vermilion)
            }

            if let count = communityCount, count >= Community.visibleCountThreshold {
                Label(tr("\(count) personnes ont essayé aujourd'hui", "\(count) people tried today"),
                      systemImage: "person.2")
                    .font(.footnote)
                    .foregroundStyle(Color.ink.opacity(0.6))
            }

            HStack(alignment: .firstTextBaseline) {
                Text(tr("Essayer, c'est déjà réussir.", "Trying is already succeeding."))
                    .font(.system(.footnote, design: .serif).italic())
                    .foregroundStyle(Color.ink.opacity(0.55))
                Spacer(minLength: 8)
                if dislikedDay == Community.dayKey(today) {
                    Text(tr("Merci, c'est noté", "Thanks, noted"))
                        .font(.footnote)
                        .foregroundStyle(Color.ink.opacity(0.45))
                } else {
                    Button(tr("Pas pour moi", "Not for me")) { router.showsDislikeOptions = true }
                        .font(.footnote)
                        .foregroundStyle(Color.ink.opacity(0.55))
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .confirmationDialog(tr("Ce défi n'est pas pour toi ?", "Not your kind of challenge?"), isPresented: $router.showsDislikeOptions,
                            titleVisibility: .visible) {
            // Une fois l'essai fait, un remplaçant n'aurait plus de sens.
            ForEach(Self.dislikeReasons.filter { !triedToday || $0.id != Self.notApplicable }, id: \.id) { reason in
                Button(reason.label) { dislike(reason: reason.id) }
            }
            Button(tr("Annuler", "Cancel"), role: .cancel) {}
        } message: {
            Text(tr("Ta réponse est anonyme et nous aide à choisir les défis.", "Your answer is anonymous and helps us choose the challenges."))
        }
    }

    private var attemptsLabel: String {
        let count = seasonAttempts
        let goal = Int(TreeModel.fullGrowthAttempts)
        return switch count {
        case 0: tr("Ton arbre attend ton premier essai \(realSeason.thisSeason)",
                   "Your tree is waiting for your first try \(realSeason.thisSeason)")
        case 1: tr("1 essai \(realSeason.thisSeason)", "1 try \(realSeason.thisSeason)")
        case goal...: tr("\(count) essais \(realSeason.thisSeason) : arbre en pleine forme",
                         "\(count) tries \(realSeason.thisSeason): tree in full bloom")
        default: tr("\(count) essais \(realSeason.thisSeason)", "\(count) tries \(realSeason.thisSeason)")
        }
    }

    private func attempt() {
        let now = Date.now
        let tried = challenge
        withAnimation(.easeInOut(duration: 0.4)) {
            store.attempt(tried, on: now)
        }
        burstDate = now
        previewsFullGrowth = false
        syncProgress(duration: 2.2)
        if let count = communityCount { communityCount = count + 1 }
        Task { await Community.recordAttempt(challenge: tried, on: now) }
    }

    private func dislike(reason: String) {
        let day = today
        let disliked = challenge
        dislikedDay = Community.dayKey(day)
        if reason == Self.notApplicable && !triedToday {
            withAnimation(.easeInOut(duration: 0.4)) { replacedDay = Community.dayKey(day) }
        }
        Task { await Community.recordDislike(challenge: disliked, on: day, reason: reason) }
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
