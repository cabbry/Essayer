import Foundation

/// Les défis du jour. Tout le monde a le même défi le même jour, et l'ordre
/// est mélangé une fois pour toutes pour ne pas suivre la liste.
enum Challenges {
    static let all: [String] = [
        "Écris un mot sur un papier, prends-le en photo et envoie-le à quelqu'un que tu aimes bien.",
        "Appelle quelqu'un que tu n'as pas appelé depuis longtemps.",
        "Dis merci à quelqu'un pour une chose précise.",
        "Fais un compliment sincère à quelqu'un que tu ne connais pas.",
        "Envoie une vieille photo à la personne qui est dessus.",
        "Demande à quelqu'un comment ça va, vraiment, et écoute la réponse.",
        "Marche dix minutes sans ton téléphone.",
        "Cuisine quelque chose pour quelqu'un.",
        "Écris à quelqu'un qui t'a aidé un jour, même il y a longtemps.",
        "Laisse un mot gentil quelque part pour la personne qui le trouvera.",
        "Envoie un message vocal plutôt qu'un texto.",
        "Pardonne-toi une petite erreur d'hier.",
        "Demande un conseil à quelqu'un dont tu admires le travail.",
        "Apprends le prénom de quelqu'un que tu croises souvent.",
        "Raconte une blague à quelqu'un, même une nulle.",
        "Range un tiroir et donne ce qui ne te sert plus.",
        "Envoie une chanson à quelqu'un en lui disant à quoi elle te fait penser.",
        "Regarde le ciel pendant une minute entière.",
        "Dis non à quelque chose qui ne te fait pas envie.",
        "Propose ton aide à un voisin.",
        "Écris trois choses qui se sont bien passées aujourd'hui.",
        "Souhaite une belle journée à la personne qui te sert un café.",
        "Rappelle à quelqu'un un bon souvenir que vous avez en commun.",
        "Goûte un plat que tu n'as jamais mangé.",
        "Prends un autre chemin pour rentrer.",
        "Écris une carte postale et poste-la.",
        "Dessine quelque chose, même mal, et envoie-le à quelqu'un.",
        "Remarque une chose que quelqu'un fait bien, et dis-le-lui.",
        "Lis une page d'un livre que tu as abandonné.",
        "Envoie un message à quelqu'un juste pour dire que tu penses à cette personne.",
        "Dis à quelqu'un ce que tu admires chez cette personne.",
        "Fais une pause de cinq minutes, les yeux fermés.",
        "Demande à un proche de te raconter une histoire de son enfance.",
        "Offre une fleur, même cueillie au bord du chemin.",
        "Apprends à dire merci dans une nouvelle langue.",
        "Partage un repas sans écran.",
        "Laisse passer quelqu'un devant toi dans une file.",
        "Réponds au message que tu repousses depuis des jours.",
        "Excuse-toi pour quelque chose que tu regrettes.",
        "Photographie une chose belle que personne ne remarque.",
        "Écris une lettre à toi-même dans un an.",
        "Chante sous la douche, fort.",
        "Invite quelqu'un à marcher avec toi.",
        "Dis « je t'aime » à quelqu'un qui ne s'y attend pas.",
        "Arrose une plante, ou adopte-en une.",
        "Apprends quelque chose de nouveau en dix minutes.",
        "Remercie quelqu'un qui fait un métier qu'on ne remercie jamais.",
        "Écoute un album en entier, sans rien faire d'autre.",
        "Envoie un message à ta famille, sans raison particulière.",
        "Fais rire quelqu'un.",
        "Dis bonjour à tes voisins.",
        "Note l'idée qui te trotte dans la tête depuis longtemps.",
        "Recommande un livre ou un film à quelqu'un, en expliquant pourquoi.",
        "Prends des nouvelles de quelqu'un qui traverse une période difficile.",
        "Fais cinq minutes de la chose que tu repousses depuis une semaine.",
        "Souris à la première personne que tu croises.",
        "Laisse un avis sympa à un petit commerce que tu aimes.",
        "Écris un haïku sur ta journée : cinq, sept, cinq syllabes.",
        "Parle à quelqu'un d'une personne qui t'a marqué, et pourquoi.",
        "Demande de l'aide pour quelque chose, même tout petit.",
    ]

    static func forDay(_ date: Date, calendar: Calendar = .current) -> String {
        let reference = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let days = calendar.dateComponents([.day], from: reference, to: calendar.startOfDay(for: date)).day ?? 0
        let index = ((days % order.count) + order.count) % order.count
        return all[order[index]]
    }

    private static let order: [Int] = {
        var rng = SeededGenerator(seed: 0xE55A_1E2)
        return Array(all.indices).shuffled(using: &rng)
    }()
}
