import SwiftUI

/// Le décor suit les saisons du vrai calendrier : cerisiers en fleurs au
/// printemps, verdure l'été, érables rouges l'automne, neige l'hiver.
enum Season: Int, CaseIterable, Hashable {
    case spring, summer, autumn, winter

    init(date: Date, calendar: Calendar = .current) {
        switch calendar.component(.month, from: date) {
        case 3...5: self = .spring
        case 6...8: self = .summer
        case 9...11: self = .autumn
        default: self = .winter
        }
    }

    var next: Season {
        Season(rawValue: (rawValue + 1) % Season.allCases.count) ?? .spring
    }

    var name: String {
        switch self {
        case .spring: "Printemps"
        case .summer: "Été"
        case .autumn: "Automne"
        case .winter: "Hiver"
        }
    }

    var kanji: String {
        switch self {
        case .spring: "春"
        case .summer: "夏"
        case .autumn: "秋"
        case .winter: "冬"
        }
    }

    var skyTop: Color {
        switch self {
        case .spring: Color(hex: 0xF4D9DF)
        case .summer: Color(hex: 0xCBE3E6)
        case .autumn: Color(hex: 0xF1D6B8)
        case .winter: Color(hex: 0xC9D4DF)
        }
    }

    var skyBottom: Color {
        switch self {
        case .spring: Color(hex: 0xFBF5EE)
        case .summer: Color(hex: 0xF7F3E8)
        case .autumn: Color(hex: 0xFAF2E6)
        case .winter: Color(hex: 0xF1F3F5)
        }
    }

    var ground: Color {
        switch self {
        case .spring: Color(hex: 0xE3D8C4)
        case .summer: Color(hex: 0xD3D9B8)
        case .autumn: Color(hex: 0xDCC8A8)
        case .winter: Color(hex: 0xEDF0F2)
        }
    }

    var sun: Color {
        switch self {
        case .spring: Color(hex: 0xE88A9C)
        case .summer: Color(hex: 0xF0B85A)
        case .autumn: Color(hex: 0xD9553E)
        case .winter: Color(hex: 0xB9C4CF)
        }
    }

    /// Les couleurs de ce qui pousse sur l'arbre (fleurs, feuilles ou neige).
    var foliage: [Color] {
        switch self {
        case .spring:
            [Color(hex: 0xF6B7C6), Color(hex: 0xF3A5B8), Color(hex: 0xFAD0DA), Color(hex: 0xEE90A8)]
        case .summer:
            [Color(hex: 0x7FA66B), Color(hex: 0x5E8C55), Color(hex: 0x9CBF7D), Color(hex: 0x4F7A4A)]
        case .autumn:
            [Color(hex: 0xC8452F), Color(hex: 0xDD6B35), Color(hex: 0xE89A3C), Color(hex: 0xB33A3A), Color(hex: 0xF0B85A)]
        case .winter:
            [Color(hex: 0xFFFFFF), Color(hex: 0xF4F7FA), Color(hex: 0xE6EDF3)]
        }
    }

    /// Combien d'éléments tombent en permanence dans le décor.
    var ambientCount: Int {
        switch self {
        case .spring: 16
        case .summer: 5
        case .autumn: 12
        case .winter: 36
        }
    }

    /// Vitesse de chute, en points par seconde.
    var fallSpeed: Double {
        switch self {
        case .spring: 34
        case .summer: 28
        case .autumn: 42
        case .winter: 30
        }
    }

    var particleSize: Double {
        switch self {
        case .spring: 5
        case .summer: 6
        case .autumn: 6.5
        case .winter: 2.6
        }
    }
}
