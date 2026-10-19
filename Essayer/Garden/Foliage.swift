import SwiftUI

/// Dessine ce qui pousse sur l'arbre et ce qui en tombe, selon la saison.
enum Foliage {
    /// Ce qui pousse : fleur de cerisier, feuille ou petit tas de neige.
    static func drawBlossom(_ context: GraphicsContext, season: Season, at center: CGPoint,
                            radius: CGFloat, rotation: Double, color: Color) {
        guard radius > 0.1 else { return }
        switch season {
        case .spring:
            var petals = Path()
            for index in 0..<5 {
                let angle = rotation + Double(index) * 2 * Double.pi / 5
                let petalCenter = CGPoint(x: center.x + CGFloat(cos(angle)) * radius * 0.55,
                                          y: center.y + CGFloat(sin(angle)) * radius * 0.55)
                petals.addEllipse(in: CGRect(x: petalCenter.x - radius * 0.48, y: petalCenter.y - radius * 0.48,
                                             width: radius * 0.96, height: radius * 0.96))
            }
            context.fill(petals, with: .color(color))
            let heart = CGRect(x: center.x - radius * 0.2, y: center.y - radius * 0.2,
                               width: radius * 0.4, height: radius * 0.4)
            context.fill(Path(ellipseIn: heart), with: .color(.blossomHeart))
        case .summer, .autumn:
            context.fill(leaf(at: center, length: radius, rotation: rotation, flip: 1), with: .color(color))
        case .winter:
            let puff = CGRect(x: center.x - radius * 0.8, y: center.y - radius * 0.6,
                              width: radius * 1.6, height: radius * 1.2)
            context.fill(Path(ellipseIn: puff), with: .color(color))
            context.stroke(Path(ellipseIn: puff), with: .color(Color.ink.opacity(0.07)), lineWidth: 0.6)
        }
    }

    /// Ce qui tombe : pétale qui tournoie, feuille ou flocon.
    static func drawFalling(_ context: GraphicsContext, season: Season, at center: CGPoint,
                            radius: CGFloat, rotation: Double, color: Color) {
        switch season {
        case .spring:
            // Le pétale se retourne en tombant : on l'aplatit avec un cosinus.
            let flip = max(0.25, abs(cos(rotation * 1.3)))
            let petal = Path(ellipseIn: CGRect(x: -radius * 0.6, y: -radius * 0.38,
                                               width: radius * 1.2, height: radius * 0.76))
                .applying(CGAffineTransform(translationX: center.x, y: center.y)
                    .rotated(by: CGFloat(rotation))
                    .scaledBy(x: CGFloat(flip), y: 1))
            context.fill(petal, with: .color(color))
        case .summer, .autumn:
            let flip = max(0.3, abs(cos(rotation * 1.1)))
            context.fill(leaf(at: center, length: radius, rotation: rotation, flip: flip), with: .color(color))
        case .winter:
            context.fill(Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius,
                                                width: radius * 2, height: radius * 2)),
                         with: .color(color))
        }
    }

    private static func leaf(at center: CGPoint, length: CGFloat, rotation: Double, flip: Double) -> Path {
        Path(ellipseIn: CGRect(x: -length, y: -length * 0.42, width: length * 2, height: length * 0.84))
            .applying(CGAffineTransform(translationX: center.x, y: center.y)
                .rotated(by: CGFloat(rotation))
                .scaledBy(x: 1, y: CGFloat(flip)))
    }
}
