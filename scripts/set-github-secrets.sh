#!/usr/bin/env bash
# Renseigne les secrets GitHub nécessaires au workflow TestFlight.
# À lancer depuis Git Bash, une fois le profil « Essayer AppStore » téléchargé :
#   bash scripts/set-github-secrets.sh
# Les valeurs vont directement des fichiers locaux vers GitHub (gh secret set) :
# rien n'est affiché ni écrit sur le disque.
set -euo pipefail

REPO=cabbry/Essayer

read -rp "Team ID Apple (10 caractères) : " TEAM_ID
read -rp "Chemin de la clé API App Store Connect (AuthKey_XXXXXXXXXX.p8) : " P8
DEFAULT_KEY_ID=$(basename "$P8" .p8 | sed -n 's/^AuthKey_//p')
read -rp "Key ID de la clé API [${DEFAULT_KEY_ID}] : " KEY_ID
KEY_ID=${KEY_ID:-$DEFAULT_KEY_ID}
read -rp "Issuer ID : " ISSUER_ID
read -rp "Chemin du certificat Apple Distribution (.p12) : " P12
read -rsp "Mot de passe du .p12 : " P12_PASSWORD; echo
read -rp "Chemin du profil « Essayer AppStore » (.mobileprovision) : " PROFILE

for file in "$P8" "$P12" "$PROFILE"; do
  [ -f "$file" ] || { echo "Fichier introuvable : $file" >&2; exit 1; }
done

gh secret set APPLE_TEAM_ID -R "$REPO" --body "$TEAM_ID"
gh secret set ASC_KEY_ID -R "$REPO" --body "$KEY_ID"
gh secret set ASC_ISSUER_ID -R "$REPO" --body "$ISSUER_ID"
gh secret set ASC_PRIVATE_KEY -R "$REPO" < "$P8"
base64 -w0 "$P12" | gh secret set DIST_P12_B64 -R "$REPO"
gh secret set DIST_P12_PASSWORD -R "$REPO" --body "$P12_PASSWORD"
base64 -w0 "$PROFILE" | gh secret set PROVISIONING_PROFILE_B64 -R "$REPO"

echo
echo "Secrets renseignés sur $REPO :"
gh secret list -R "$REPO"
echo
echo "Pour lancer l'envoi vers TestFlight : gh workflow run testflight.yml -R $REPO"
