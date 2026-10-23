import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// Encre de Chine, pour le texte.
    static let ink = Color(hex: 0x2E2A28)
    /// Vermillon des torii, pour le bouton.
    static let vermilion = Color(hex: 0xB9442F)
    /// Écorce du cerisier.
    static let bark = Color(hex: 0x4A3B34)
    /// Tiges des lianes.
    static let vine = Color(hex: 0x5F5B3C)
    /// Cœur des fleurs de cerisier.
    static let blossomHeart = Color(hex: 0xC9506E)
}
