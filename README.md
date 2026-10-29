# Essayer

Une idée d'application de Kyan Khojandi : chaque jour, un petit défi, souvent
tourné vers les autres (écrire un mot à quelqu'un, appeler une personne perdue
de vue…). On ne coche pas « réussi », on dit **« J'ai essayé »**, parce
qu'essayer, c'est déjà une forme de réussite.

À chaque essai, un cerisier grandit et se couvre de fleurs. Le décor suit les
saisons : cerisiers en fleurs au printemps, verdure l'été, érables rouges
l'automne, neige l'hiver.

## Compilation

SwiftUI, **iOS 17**, iPhone uniquement. L'appli est compilée et livrée dans
TestFlight par GitHub Actions (runners macOS) : pas besoin de Mac.

- `project.yml` : définition XcodeGen (le `.xcodeproj` est généré, jamais commité)
- `.github/workflows/testflight.yml` : archive iOS + upload TestFlight à chaque push sur `main`

Sans les secrets Apple, le workflow fait une **compilation seule** (sans
signature). C'est pratique pour vérifier que le code compile. On peut aussi la
lancer à la main : Actions → TestFlight → Run workflow, case « Compilation seule ».

Astuces pour tester :
- toucher le kanji de la saison (en haut à droite) fait défiler les saisons,
  pour voir les quatre décors sans attendre ;
- un appui long sur le titre « Essayer » montre l'arbre et les lianes au
  maximum de la saison (30 essais) ; un second appui long revient à la réalité.

## Mise en place TestFlight (à faire une fois)

1. **App ID** : developer.apple.com → Identifiers → « + » → `com.cabbry.essayer`.
2. **Profil App Store** pour cet App ID, avec le certificat Apple Distribution
   existant, nommé exactement **« Essayer AppStore »**.
3. **Créer l'app dans App Store Connect** : Apps → « + » → New App, bundle ID
   `com.cabbry.essayer`, SKU libre.
4. **Secrets GitHub** : lancer `bash scripts/set-github-secrets.sh` depuis Git
   Bash (il demande chaque valeur et l'envoie directement à GitHub), ou les
   saisir dans Settings → Secrets and variables → Actions :
   | Secret | Contenu |
   |---|---|
   | `APPLE_TEAM_ID` | Team ID (10 caractères) |
   | `ASC_KEY_ID` | Key ID de la clé API App Store Connect |
   | `ASC_ISSUER_ID` | Issuer ID |
   | `ASC_PRIVATE_KEY` | Contenu texte intégral du fichier `.p8` |
   | `DIST_P12_B64` | Certificat Apple Distribution (`.p12`) en base64 |
   | `DIST_P12_PASSWORD` | Mot de passe du `.p12` |
   | `PROVISIONING_PROFILE_B64` | Profil « Essayer AppStore » en base64 |
5. Pousser sur `main`. Le build apparaît dans TestFlight au bout d'environ 15 min.

Le numéro de build est dérivé automatiquement du numéro d'exécution GitHub Actions.

## Organisation

| Dossier | Contenu |
| --- | --- |
| `Essayer/App` | Point d'entrée de l'appli |
| `Essayer/Model` | Les essais (stockés sur l'appareil), les défis du jour, les saisons |
| `Essayer/Garden` | Le jardin dessiné : fond, cerisier généré, lianes, pétales qui tombent |
| `Essayer/Views` | L'écran principal et l'historique des essais |
| `Essayer/Support` | Petits utilitaires (couleurs, géométrie, aléatoire reproductible) |

## Comment pousse l'arbre

- L'arbre est généré une fois pour toutes à partir d'une graine : il a toujours
  la même forme.
- **L'arbre repart de zéro à chaque saison** (1er mars, 1er juin,
  1er septembre, 1er décembre) : seuls les essais de la saison en cours comptent.
- Au début de la saison, c'est une jeune pousse. Branches, taille et fleurs
  grandissent avec les essais, jusqu'au **maximum à 30 essais**.
- Des **lianes** rampent le long des deux bords de l'écran : elles sortent de
  l'écran et y rentrent, et s'allongent elles aussi jusqu'à 30 essais.
- L'arbre ne meurt jamais et ne perd rien si on rate un jour.
- Un seul essai par jour : celui du défi du jour.
- **Les défis** (`Essayer/Model/Challenges.swift`) : 274 défis généraux et
  24 par saison. Un jour sur quatre est un défi de saison, et aucun ne revient
  dans la même saison. Les défis généraux reviennent environ une fois par an.
  Tout le monde a le même défi le même jour.
- **Notifications** : le défi du jour le matin (9 h par défaut) et une relance
  en fin d'après-midi (17 h par défaut) si l'essai n'est pas fait. La relance
  porte deux boutons : « J'ai essayé » (enregistre l'essai sans ouvrir
  l'appli) et « Pas pour moi » (ouvre l'appli sur le choix de la raison).
  Chaque notification s'active et se règle à l'heure voulue dans l'écran
  **Réglages** (roue dentée). Elles sont programmées pour les 30 jours
  suivants, et reprogrammées à chaque ouverture de l'appli ou changement de
  réglage.
- **Statistiques anonymes (CloudKit)** : « J'ai essayé » et « Pas pour moi »
  déposent un enregistrement anonyme (jour, défi, raison) dans la base
  publique `iCloud.com.cabbry.essayer`. Le compteur « X personnes ont essayé
  aujourd'hui » s'affiche à partir de 10. Pour retirer un défi sans mise à
  jour, créer dans la console CloudKit (Production) un enregistrement
  `DisabledChallenge` dont le champ `challenge` contient le texte exact du
  défi. Le partage se coupe dans les Réglages.
