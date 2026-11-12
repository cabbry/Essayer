import Foundation

extension Calendar {
    /// Le calendrier grégorien, dans le fuseau horaire de l'appareil.
    ///
    /// Tout ce qui découpe les jours (défi du jour, saisons, compteur
    /// CloudKit) passe par lui plutôt que par `Calendar.current` : un iPhone
    /// réglé en calendrier japonais, bouddhiste, hébraïque… aurait sinon un
    /// autre défi que tout le monde, d'autres saisons et une autre clé de jour.
    static var gregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale = .current
        return calendar
    }
}
