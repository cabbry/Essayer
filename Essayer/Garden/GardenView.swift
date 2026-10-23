import SwiftUI

/// Le jardin complet : fond, cerisier et ce qui tombe.
struct GardenView: View {
    let season: Season
    let progress: Double
    let burstDate: Date?

    var body: some View {
        ZStack {
            ZStack {
                GardenBackground(season: season)
                VinesView(season: season, progress: progress)
                TreeView(season: season, progress: progress)
            }
            .id(season)
            .transition(.opacity)

            ParticlesView(season: season, progress: progress, burstDate: burstDate)
        }
    }
}
