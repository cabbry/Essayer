import Foundation

/// L'appli parle français aux personnes dont l'iPhone est en français, et
/// anglais à toutes les autres.
///
/// Les textes sont écrits côte à côte (`tr("…", "…")`) plutôt que dans un
/// catalogue : il n'y a que deux langues, et les défis gardent leur texte
/// français comme identifiant (CloudKit, historique, défis retirés).
enum Lang {
    /// `Locale.preferredLanguages` suit aussi la langue choisie pour l'appli
    /// seule (Réglages → Essayer → Langue) et l'argument `-AppleLanguages`.
    static let isFrench: Bool = (Locale.preferredLanguages.first ?? "fr").hasPrefix("fr")
}

/// Le texte dans la langue de l'utilisateur.
func tr(_ french: String, _ english: String) -> String {
    Lang.isFrench ? french : english
}
