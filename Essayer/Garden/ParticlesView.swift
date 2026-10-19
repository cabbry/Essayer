import SwiftUI

/// Ce qui tombe dans le jardin : pétales, feuilles ou neige. Après un essai,
/// une pluie de pétales part de l'arbre pendant quelques secondes.
struct ParticlesView: View {
    let season: Season
    let progress: Double
    let burstDate: Date?

    private static let burstCount = 28
    private static let burstDuration = 4.5

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                drawAmbient(context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
                if let burstDate {
                    drawBurst(context, size: size, age: timeline.date.timeIntervalSince(burstDate))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func drawAmbient(_ context: GraphicsContext, size: CGSize, time: Double) {
        let palette = season.foliage
        let travel = Double(size.height) + 60
        for index in 0..<season.ambientCount {
            let column = Noise.unit(index, 1)
            let pace = Noise.unit(index, 2)
            let phase = Noise.unit(index, 3)
            let swing = Noise.unit(index, 4)
            let twist = Noise.unit(index, 5)
            let grain = Noise.unit(index, 6)

            let speed = season.fallSpeed * (0.7 + pace * 0.6)
            let period = travel / speed
            let y = (time + phase * period).truncatingRemainder(dividingBy: period) * speed - 30
            let sway = sin(time * (0.5 + swing * 0.7) + twist * 2 * Double.pi) * (12 + swing * 26)
            let x = column * Double(size.width) + sway

            Foliage.drawFalling(context, season: season, at: CGPoint(x: x, y: y),
                                radius: CGFloat(season.particleSize * (0.7 + grain * 0.6)),
                                rotation: time * (0.6 + swing) + twist * 6,
                                color: palette[index % palette.count].opacity(0.85))
        }
    }

    private func drawBurst(_ context: GraphicsContext, size: CGSize, age: Double) {
        guard age >= 0, age < Self.burstDuration else { return }
        let layout = GardenLayout(size: size)
        let crown = layout.crown(progress: progress)
        let spread = Double(layout.treeSize * TreeModel.scale(for: progress))
        let palette = season.foliage
        let fade = 1 - age / Self.burstDuration

        for index in 0..<Self.burstCount {
            let startX = Double(crown.x) + (Noise.unit(index, 11) - 0.5) * spread * 0.9
            let startY = Double(crown.y) + (Noise.unit(index, 12) - 0.5) * spread * 0.5
            let drift = (Noise.unit(index, 13) - 0.5) * 70
            let twist = Noise.unit(index, 14) * 6
            let x = startX + drift * age + sin(age * 2 + twist) * 10
            let y = startY + 18 * age + 9 * age * age

            Foliage.drawFalling(context, season: season, at: CGPoint(x: x, y: y),
                                radius: CGFloat(season.particleSize * 1.1),
                                rotation: age * 2.4 + twist,
                                color: palette[index % palette.count].opacity(0.95 * fade))
        }
    }
}
