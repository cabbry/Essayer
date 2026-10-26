# Essayer 1.0 — fiche App Store

Textes à saisir dans App Store Connect (Essayer → Distribution → iOS 1.0).
**Pas d'emoji dans ces champs** : App Store Connect les refuse.

## Informations sur l'app

| Champ | Valeur |
|---|---|
| Nom (30 max) | Essayer |
| Sous-titre (30 max) | Un petit défi par jour |
| Catégorie principale | Style de vie |
| Catégorie secondaire | Santé et forme |
| Prix | Gratuit |
| Copyright | 2026 Jr Cabbry |
| URL d'assistance | https://cabbry.github.io/essayer-site/ |
| URL marketing | https://cabbry.github.io/essayer-site/ |
| URL de confidentialité | https://cabbry.github.io/essayer-site/privacy.html |

## Texte promotionnel (170 max)

```
Chaque jour, un petit défi pour les autres et pour soi. Dis « J'ai essayé » et regarde ton cerisier fleurir, saison après saison.
```

## Description (4000 max)

```
Essayer, c'est déjà réussir.

Chaque jour, Essayer te propose un petit défi, souvent tourné vers les autres : écrire un mot à quelqu'un que tu aimes bien, appeler une personne perdue de vue, dire merci pour une chose précise, offrir une fleur… Ici, on ne coche pas « réussi ». On dit simplement « J'ai essayé ».

UN CERISIER QUI GRANDIT AVEC TOI
À chaque essai, ton arbre pousse et se couvre de fleurs, et des lianes grimpent le long de l'écran. L'arbre repart d'une jeune pousse au début de chaque saison et atteint sa pleine forme en 30 essais.

LE JARDIN SUIT LES SAISONS
Fleurs de cerisier au printemps, verdure l'été, érables rouges l'automne, neige l'hiver. Le décor change avec le calendrier, et des défis de saison viennent s'ajouter aux défis de tous les jours.

DES CENTAINES DE PETITS DÉFIS
Des gestes simples, faisables en quelques minutes, sans matériel ni argent : remercier, prendre des nouvelles, partager un souvenir, écouter, ralentir, oser. Tout le monde reçoit le même défi le même jour.

SANS PRESSION
Rien ne se perd si tu rates un jour : l'arbre ne fane jamais. Un seul défi par jour, et un rappel doux chaque matin si tu le souhaites.

RESPECTUEUX DE TA VIE PRIVÉE
Pas de compte, pas de publicité, aucune donnée collectée. Tes essais restent sur ton iPhone.
```

## Mots-clés (100 max, séparés par des virgules sans espace)

```
défi,quotidien,bienveillance,gratitude,habitude,cerisier,japon,zen,gentillesse,bien-être,saisons
```

## Captures d'écran

iPhone 6,9" (1320 x 2868), générées par le workflow « Captures App Store »
(`.github/workflows/screenshots.yml`), dans cet ordre :

1. Printemps, arbre en pleine floraison (30 essais), bouton « J'ai essayé »
2. Automne, érables rouges (18 essais)
3. Été, verdure (24 essais), défi du jour déjà essayé
4. Hiver, neige (12 essais), défi du jour déjà essayé
5. Historique des essais

Copie locale : `E:\Projects\_Common\AppStore-Screenshots\Essayer\`.

## Confidentialité de l'app (questionnaire App Store Connect)

- Collecte de données : **Aucune donnée collectée** (« Data Not Collected »).
- Les essais sont stockés localement (UserDefaults) ; les rappels sont des
  notifications locales, sans serveur.

## Classification par âge

Répondre **Aucun / Non** à toutes les questions → **4+**.

## Notes pour la review (App Review Information)

```
Essayer has no account and no server: everything is stored on the device.

Each day the app shows one small challenge; tapping "J'ai essayé" ("I tried") records it and grows the cherry tree. Only one attempt per day is possible.

To see more of the app during the review:
- Tap the kanji at the top right to preview the four seasons (spring, summer, autumn, winter).
- Long-press the "Essayer" title to preview the tree at full growth (30 attempts); long-press again to return.
- The history of attempts is behind the book icon at the top right.

The app asks for permission to send one local notification per day (9:00) with the challenge of the day.

Thank you for the review!
```

## À ne pas mettre dans la fiche

L'idée vient d'une vidéo de Kyan Khojandi. Ne pas citer son nom ni utiliser
son image, sa voix ou la vidéo dans la fiche ou la communication sans son
accord écrit.
