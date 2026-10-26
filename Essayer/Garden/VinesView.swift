import SwiftUI

/// Les lianes qui rampent le long des deux bords de l'écran. Elles poussent
/// avec les essais de la saison, comme l'arbre, et se couvrent de feuilles.
struct VinesView: View, Animatable {
    let season: Season
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    private static let vines = VineModel.make()

    var body: some View {
        Canvas { context, size in
            for vine in Self.vines {
                draw(vine, in: context, size: size)
            }
        }
        .allowsHitTesting(false)
    }

    private func draw(_ vine: VineModel.Vine, in context: GraphicsContext, size: CGSize) {
        let fraction = TreeModel.fraction(for: progress)
        let grown = min(max((fraction - vine.delay) / (1 - vine.delay), 0), 1)
        // Les lianes partent sous l'en-tête et descendent jusqu'en bas de l'écran.
        let top = size.height * 0.17
        let fullLength = size.height - top + 40
        let length = fullLength * CGFloat(0.12 + 0.88 * grown)

        // Une seconde ondulation, décalée pour chaque liane, casse la
        // régularité de la sinusoïde : le tracé paraît plus naturel.
        let wobble = 0.35
        let wobbleRate = 1.7
        let wobblePhase = vine.phase * 3

        func angle(_ y: CGFloat) -> Double {
            2 * Double.pi * Double(y / vine.wavelength) + vine.phase
        }
        func point(_ y: CGFloat) -> CGPoint {
            let a = angle(y)
            let wave = sin(a) + wobble * sin(wobbleRate * a + wobblePhase)
            let inward = vine.inset + vine.amplitude * CGFloat(wave)
            return CGPoint(x: vine.side < 0 ? inward : size.width - inward, y: top + y)
        }
        /// dx/dy de la tige, pour orienter les feuilles.
        func slope(_ y: CGFloat) -> CGFloat {
            let a = angle(y)
            let rate = 2 * Double.pi / Double(vine.wavelength)
            let wave = cos(a) + wobble * wobbleRate * cos(wobbleRate * a + wobblePhase)
            let derivative = vine.amplitude * CGFloat(rate * wave)
            return vine.side < 0 ? derivative : -derivative
        }

        var stem = Path()
        stem.move(to: point(0))
        var y: CGFloat = 3
        while y < length {
            stem.addLine(to: point(y))
            y += 3
        }
        stem.addLine(to: point(length))
        context.stroke(stem, with: .color(.vine),
                       style: StrokeStyle(lineWidth: vine.width, lineCap: .round, lineJoin: .round))

        let palette = season.vineLeaves
        for leaf in vine.leaves {
            let leafY = leaf.position * fullLength
            guard leafY <= length else { break }
            let base = point(leafY)
            guard base.x > -24, base.x < size.width + 24 else { continue }

            // Les feuilles près du bout de la liane sont encore en train de pousser.
            let grownIn = min(max((length - leafY) / 36, 0), 1)
            guard grownIn > 0.05 else { continue }

            let stemAngle = atan2(1, Double(slope(leafY)))
            let leafAngle = stemAngle + leaf.side * (Double.pi / 2 - 0.45) + leaf.tilt
            let leafSize = leaf.size * CGFloat(grownIn)
            let direction = CGPoint(x: CGFloat(cos(leafAngle)), y: CGFloat(sin(leafAngle)))
            let bladeStart = base + direction * (leafSize * 0.3)

            var petiole = Path()
            petiole.move(to: base)
            petiole.addLine(to: bladeStart)
            context.stroke(petiole, with: .color(.vine), lineWidth: 1)

            let transform = CGAffineTransform(translationX: bladeStart.x, y: bladeStart.y)
                .rotated(by: CGFloat(leafAngle))
            var blade = Path()
            blade.move(to: .zero)
            blade.addQuadCurve(to: CGPoint(x: leafSize, y: 0), control: CGPoint(x: leafSize * 0.4, y: -leafSize * 0.6))
            blade.addQuadCurve(to: .zero, control: CGPoint(x: leafSize * 0.4, y: leafSize * 0.6))
            context.fill(blade.applying(transform), with: .color(palette[leaf.tone % palette.count]))

            var vein = Path()
            vein.move(to: .zero)
            vein.addLine(to: CGPoint(x: leafSize * 0.8, y: 0))
            context.stroke(vein.applying(transform), with: .color(.white.opacity(0.35)), lineWidth: 0.8)

            guard leaf.flower else { continue }
            if let flowerColor = season.vineFlower {
                Foliage.drawBlossom(context, season: .spring, at: base - direction * (leafSize * 0.35),
                                    radius: leafSize * 0.42, rotation: leaf.tilt * 4, color: flowerColor)
            } else if season == .winter {
                let center = bladeStart + direction * (leafSize * 0.45)
                let snow = CGRect(x: center.x - leafSize * 0.3, y: center.y - leafSize * 0.22,
                                  width: leafSize * 0.6, height: leafSize * 0.36)
                context.fill(Path(ellipseIn: snow), with: .color(.white.opacity(0.95)))
            }
        }
    }
}
