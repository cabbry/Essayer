import CoreGraphics
import Foundation

/// La forme du cerisier, générée une fois pour toutes à partir d'une graine.
///
/// Les coordonnées sont normalisées : le pied du tronc est en (0, 0), l'axe y
/// monte, et l'arbre adulte fait 1 de haut. C'est `progress` (le nombre
/// d'essais, en continu pendant l'animation) qui décide quelle part on dessine.
struct TreeModel {
    struct Branch {
        let start: CGPoint
        let end: CGPoint
        let width: CGFloat
        let depth: Int
    }

    /// Un endroit où une fleur (ou une feuille, ou de la neige) peut pousser.
    struct Anchor {
        let branch: Int
        /// Position le long de la branche, de 0 (base) à 1 (bout).
        let t: CGFloat
        let offset: CGPoint
        let rotation: Double
        let size: CGFloat
        let tone: Int
    }

    static let maxDepth = 6
    /// Nombre d'essais dans la saison pour que l'arbre (et les lianes)
    /// atteigne son maximum.
    static let fullGrowthAttempts = 30.0
    static let maxBlossoms = 450

    let branches: [Branch]
    let anchors: [Anchor]

    init(seed: UInt64 = 0xE55A) {
        var rng = SeededGenerator(seed: seed)
        var grown: [Branch] = []

        func grow(from start: CGPoint, angle: Double, length: Double, width: Double, depth: Int) {
            let end = CGPoint(x: start.x + CGFloat(cos(angle) * length),
                              y: start.y + CGFloat(sin(angle) * length))
            grown.append(Branch(start: start, end: end, width: CGFloat(width), depth: depth))
            guard depth < TreeModel.maxDepth else { return }

            let children = depth == 0 ? 2 : (rng.unit() < 0.3 ? 3 : 2)
            for index in 0..<children {
                let side = children == 2 ? (index == 0 ? -1.0 : 1.0) : Double(index - 1)
                let spread = 0.4 + rng.unit() * 0.35
                var childAngle = angle + side * spread + (rng.unit() - 0.5) * 0.2
                // Les cerisiers s'étalent, mais sans retomber vers le sol.
                childAngle += (Double.pi / 2 - childAngle) * 0.12
                let ratio = 0.7 + rng.unit() * 0.12
                grow(from: end, angle: childAngle, length: length * ratio, width: width * 0.7, depth: depth + 1)
            }
        }

        grow(from: .zero, angle: Double.pi / 2 + 0.05, length: 0.3, width: 0.078, depth: 0)

        // Normalise : 1 de haut, au plus 0,7 de chaque côté du tronc.
        let height = grown.map { max($0.start.y, $0.end.y) }.max() ?? 1
        let halfWidth = grown.map { max(abs($0.start.x), abs($0.end.x)) }.max() ?? 1
        let scale = 1 / max(height, halfWidth / 0.7)
        branches = grown.map {
            Branch(start: $0.start * scale, end: $0.end * scale, width: $0.width * scale, depth: $0.depth)
        }

        var anchors: [Anchor] = []
        for (index, branch) in branches.enumerated() where branch.depth >= 1 {
            let count = branch.depth >= 4 ? 3 : (branch.depth >= 2 ? 2 : 1)
            for _ in 0..<count {
                anchors.append(Anchor(
                    branch: index,
                    t: CGFloat(0.35 + rng.unit() * 0.65),
                    offset: CGPoint(x: (rng.unit() - 0.5) * 0.05, y: (rng.unit() - 0.5) * 0.05),
                    rotation: rng.unit() * 2 * Double.pi,
                    size: CGFloat(0.75 + rng.unit() * 0.5),
                    tone: Int(rng.next() % 1000)
                ))
            }
        }
        anchors.shuffle(using: &rng)
        self.anchors = anchors
    }

    /// Où en est la saison, de 0 (une jeune pousse) à 1 (arbre au maximum).
    static func fraction(for progress: Double) -> Double {
        min(max(progress / fullGrowthAttempts, 0), 1)
    }

    /// Jusqu'à quelle profondeur de branches l'arbre a poussé. Un niveau
    /// partiel dessine des branches en train de pousser.
    static func growthLevel(for progress: Double) -> Double {
        2.2 + fraction(for: progress) * (Double(maxDepth + 1) - 2.2)
    }

    /// La taille de l'arbre : une pousse en début de saison, adulte à 30 essais.
    static func scale(for progress: Double) -> CGFloat {
        CGFloat(0.55 + 0.45 * fraction(for: progress))
    }

    /// Combien de fleurs (ou feuilles, ou neige) portent les branches.
    static func blossomCount(for progress: Double) -> Double {
        fraction(for: progress) * Double(maxBlossoms)
    }

    /// Un endroit de fleur est visible dès que sa branche a poussé jusque-là.
    func isVisible(_ anchor: Anchor, growth: Double) -> Bool {
        Double(branches[anchor.branch].depth) + Double(anchor.t) <= growth
    }
}
