import SwiftUI

/// Le cerisier. `progress` est le nombre d'essais : quand il passe de n à n + 1
/// avec une animation, les branches poussent et les nouvelles fleurs éclosent.
struct TreeView: View, Animatable {
    let season: Season
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    private static let model = TreeModel()

    var body: some View {
        Canvas { context, size in
            draw(context, size: size)
        }
    }

    private func draw(_ context: GraphicsContext, size: CGSize) {
        let model = Self.model
        let layout = GardenLayout(size: size)
        let growth = TreeModel.growthLevel(for: progress)
        let scale = layout.treeSize * TreeModel.scale(for: progress)
        let base = layout.base

        func project(_ point: CGPoint) -> CGPoint {
            CGPoint(x: base.x + point.x * scale, y: base.y - point.y * scale)
        }

        let shadowWidth = scale * 0.9
        context.fill(Path(ellipseIn: CGRect(x: base.x - shadowWidth / 2, y: base.y - 6,
                                            width: shadowWidth, height: 12)),
                     with: .color(Color.ink.opacity(0.08)))

        for branch in model.branches {
            let grown = min(max(growth - Double(branch.depth), 0), 1)
            guard grown > 0 else { continue }
            let tip = branch.start + (branch.end - branch.start) * CGFloat(grown)
            var path = Path()
            path.move(to: project(branch.start))
            path.addLine(to: project(tip))
            context.stroke(path, with: .color(.bark),
                           style: StrokeStyle(lineWidth: max(0.8, branch.width * scale), lineCap: .round))
        }

        let visible = model.anchors.filter { model.isVisible($0, growth: growth) }
        guard !visible.isEmpty else { return }

        let total = progress * TreeModel.blossomsPerAttempt
        let count = min(Int(total.rounded(.up)), TreeModel.maxBlossoms, visible.count * 3)
        guard count > 0 else { return }
        let palette = season.foliage
        let baseRadius = layout.treeSize * 0.024

        for index in 0..<count {
            let bloom = min(max(total - Double(index), 0), 1)
            guard bloom > 0 else { continue }
            let anchor = visible[index % visible.count]
            let branch = model.branches[anchor.branch]
            var point = branch.start + (branch.end - branch.start) * anchor.t + anchor.offset
            // Quand il y a plus de fleurs que de places, on les serre autour.
            if index >= visible.count {
                point = point + CGPoint(x: (Noise.unit(index, 7) - 0.5) * 0.06,
                                        y: (Noise.unit(index, 8) - 0.5) * 0.06)
            }
            let eased = 1 - pow(1 - bloom, 3)
            Foliage.drawBlossom(context, season: season, at: project(point),
                                radius: baseRadius * anchor.size * CGFloat(eased),
                                rotation: anchor.rotation,
                                color: palette[anchor.tone % palette.count].opacity(0.92))
        }
    }
}
