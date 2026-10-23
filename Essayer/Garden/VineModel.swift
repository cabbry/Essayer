import CoreGraphics

/// La forme des lianes, tirée une fois pour toutes d'une graine.
///
/// Chaque liane descend le long d'un bord de l'écran en ondulant : sa distance
/// au bord suit une sinusoïde qui passe sous zéro, si bien qu'elle sort de
/// l'écran et y rentre. Les feuilles sont réparties sur toute sa longueur et
/// n'apparaissent qu'au fur et à mesure qu'elle pousse.
struct VineModel {
    struct Leaf {
        /// Position le long de la liane, de 0 (départ) à 1 (bas de l'écran).
        let position: CGFloat
        /// De quel côté de la tige pousse la feuille (-1 ou 1).
        let side: Double
        let size: CGFloat
        let tilt: Double
        let tone: Int
        let flower: Bool
    }

    struct Vine {
        /// -1 pour le bord gauche, 1 pour le bord droit.
        let side: CGFloat
        let inset: CGFloat
        let amplitude: CGFloat
        let wavelength: CGFloat
        let phase: Double
        let width: CGFloat
        /// Part de la saison à attendre avant que la liane commence à pousser.
        let delay: Double
        let leaves: [Leaf]
    }

    static func make(seed: UInt64 = 0x11A7E) -> [Vine] {
        var rng = SeededGenerator(seed: seed)
        var vines: [Vine] = []

        for side in [CGFloat(-1), 1] {
            for index in 0..<2 {
                var leaves: [Leaf] = []
                var position = CGFloat(0.02 + rng.unit() * 0.02)
                var leafSide = rng.unit() < 0.5 ? -1.0 : 1.0
                while position < 1 {
                    leaves.append(Leaf(
                        position: position,
                        side: leafSide,
                        size: CGFloat(11 + rng.unit() * 7),
                        tilt: (rng.unit() - 0.5) * 0.6,
                        tone: Int(rng.next() % 1000),
                        flower: rng.unit() < 0.14
                    ))
                    leafSide = -leafSide
                    position += CGFloat(0.018 + rng.unit() * 0.014)
                }

                let main = index == 0
                vines.append(Vine(
                    side: side,
                    inset: main ? 6 : 2,
                    amplitude: CGFloat(main ? 30 + rng.unit() * 8 : 22 + rng.unit() * 8),
                    wavelength: CGFloat(main ? 230 + rng.unit() * 60 : 170 + rng.unit() * 50),
                    // Démarre hors de l'écran (sinus à -1), décalée pour la seconde liane.
                    phase: -Double.pi / 2 + rng.unit() * 0.6 + Double(index) * 1.4,
                    width: main ? 2.6 : 1.7,
                    delay: main ? 0 : 0.3,
                    leaves: leaves
                ))
            }
        }
        return vines
    }
}
