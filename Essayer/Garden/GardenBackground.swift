import SwiftUI

/// Le fond du jardin : ciel, soleil, mont Fuji au loin, sol ratissé et pierres.
struct GardenBackground: View {
    let season: Season

    var body: some View {
        Canvas { context, size in
            let layout = GardenLayout(size: size)
            let width = size.width
            let height = size.height
            let groundY = layout.groundY

            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .linearGradient(Gradient(colors: [season.skyTop, season.skyBottom]),
                                      startPoint: .zero, endPoint: CGPoint(x: 0, y: groundY))
            )

            // Sous l'en-tête, pour ne pas passer derrière le kanji de la saison.
            let sunRadius = width * 0.12
            let sun = CGRect(x: width * 0.72 - sunRadius, y: height * 0.31 - sunRadius,
                             width: sunRadius * 2, height: sunRadius * 2)
            context.fill(Path(ellipseIn: sun), with: .color(season.sun.opacity(0.32)))

            var mountain = Path()
            mountain.move(to: CGPoint(x: -width * 0.05, y: groundY))
            mountain.addQuadCurve(to: CGPoint(x: width * 0.27, y: groundY - height * 0.19),
                                  control: CGPoint(x: width * 0.17, y: groundY - height * 0.04))
            mountain.addLine(to: CGPoint(x: width * 0.35, y: groundY - height * 0.19))
            mountain.addQuadCurve(to: CGPoint(x: width * 0.72, y: groundY),
                                  control: CGPoint(x: width * 0.46, y: groundY - height * 0.04))
            mountain.closeSubpath()
            context.fill(mountain, with: .color(Color.ink.opacity(0.05)))

            var snowCap = Path()
            snowCap.move(to: CGPoint(x: width * 0.234, y: groundY - height * 0.16))
            snowCap.addLine(to: CGPoint(x: width * 0.27, y: groundY - height * 0.19))
            snowCap.addLine(to: CGPoint(x: width * 0.35, y: groundY - height * 0.19))
            snowCap.addLine(to: CGPoint(x: width * 0.39, y: groundY - height * 0.16))
            snowCap.addLine(to: CGPoint(x: width * 0.34, y: groundY - height * 0.168))
            snowCap.addLine(to: CGPoint(x: width * 0.31, y: groundY - height * 0.158))
            snowCap.addLine(to: CGPoint(x: width * 0.28, y: groundY - height * 0.168))
            snowCap.closeSubpath()
            context.fill(snowCap, with: .color(.white.opacity(0.7)))

            var ground = Path()
            ground.move(to: CGPoint(x: 0, y: groundY))
            ground.addQuadCurve(to: CGPoint(x: width, y: groundY - 8),
                                control: CGPoint(x: width / 2, y: groundY - 24))
            ground.addLine(to: CGPoint(x: width, y: height))
            ground.addLine(to: CGPoint(x: 0, y: height))
            ground.closeSubpath()
            context.fill(ground, with: .color(season.ground))

            // Le sable ratissé du jardin sec.
            for index in 1...6 {
                let y = groundY + CGFloat(index) * 13
                var rake = Path()
                rake.move(to: CGPoint(x: 0, y: y))
                rake.addQuadCurve(to: CGPoint(x: width, y: y - 8), control: CGPoint(x: width / 2, y: y - 22))
                context.stroke(rake, with: .color(Color.ink.opacity(0.06)), lineWidth: 1)
            }

            let stones: [(x: CGFloat, y: CGFloat, rx: CGFloat, ry: CGFloat)] = [
                (0.17, 34, 22, 11), (0.25, 40, 11, 6), (0.84, 26, 16, 8),
            ]
            for stone in stones {
                let rect = CGRect(x: width * stone.x - stone.rx, y: groundY + stone.y - stone.ry,
                                  width: stone.rx * 2, height: stone.ry * 2)
                context.fill(Path(ellipseIn: rect.insetBy(dx: -6, dy: -3)), with: .color(Color.ink.opacity(0.05)))
                context.fill(Path(ellipseIn: rect), with: .color(Color(hex: 0x6E6862)))
            }
        }
    }
}
