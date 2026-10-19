import CoreGraphics

/// Où se trouvent le sol et l'arbre à l'écran. Partagé par toutes les couches
/// du jardin pour qu'elles restent alignées.
struct GardenLayout {
    let size: CGSize

    var groundY: CGFloat { size.height * 0.58 }

    /// La hauteur de l'arbre adulte.
    var treeSize: CGFloat { min(size.height * 0.36, size.width * 0.7) }

    var base: CGPoint { CGPoint(x: size.width / 2, y: groundY + 6) }

    /// Le cœur du feuillage, d'où partent les pétales après un essai.
    func crown(progress: Double) -> CGPoint {
        CGPoint(x: base.x, y: base.y - treeSize * TreeModel.scale(for: progress) * 0.62)
    }
}
