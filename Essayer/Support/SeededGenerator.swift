import Foundation

/// Générateur pseudo-aléatoire reproductible (SplitMix64) : le même arbre et
/// le même ordre de défis à chaque lancement.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// Un nombre dans [0, 1).
    mutating func unit() -> Double {
        Double(next() >> 11) * 0x1.0p-53
    }
}

/// Bruit sans état : la même valeur pour le même couple (index, sel).
/// Sert à animer les pétales sans rien stocker.
enum Noise {
    static func unit(_ index: Int, _ salt: UInt64) -> Double {
        var generator = SeededGenerator(seed: (UInt64(truncatingIfNeeded: index) &* 0x9E37_79B9_7F4A_7C15) ^ salt)
        return generator.unit()
    }
}
