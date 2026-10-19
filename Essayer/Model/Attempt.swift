import Foundation

/// Un « J'ai essayé » : le jour où il a été fait et le défi qu'il relevait.
struct Attempt: Codable, Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var challenge: String
}
