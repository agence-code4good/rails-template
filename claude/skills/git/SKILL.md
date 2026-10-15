---
name: git
description: Bonnes pratiques Git de l'agence Code4Good — branches, messages de commit, contenu d'un commit, pull requests, rebase, fichiers à ne jamais commiter, et règles de prudence pour Claude. Charger avant toute création de branche, commit, push, rebase, merge ou PR.
---

# Git

## Règles pour Claude

- **Ne jamais commiter, pousser, merger ni ouvrir de PR sans demande explicite.**
  Une autorisation vaut pour l'opération demandée, pas pour les suivantes.
- Jamais de `push --force` sur `main` / `staging` ; sur sa propre branche,
  `--force-with-lease` uniquement.
- Jamais de `--no-verify`, jamais de `git reset --hard` / `git clean -fd` /
  `git checkout -- .` sans accord : ces commandes détruisent du travail.
- Avant de commiter : `git status` et `git diff --staged` relus, `bin/ci` vert (ou
  au minimum `bin/rubocop` + tests concernés).
- Ajouter les fichiers nommément (`git add app/models/post.rb …`) plutôt que
  `git add -A`, pour ne pas embarquer un fichier non voulu.

## Branches

- `main` = ce qui est en production (ou prêt à y aller). On ne commite pas
  directement dessus.
- Une branche par sujet, courte durée de vie, nommée `type/description-courte` :
  - `feature/inscription-benevoles`
  - `fix/doublon-email-confirmation`
  - `chore/maj-rails-8-1-4`
- Se resynchroniser régulièrement : `git pull --rebase origin main` sur sa branche
  tant qu'elle n'est pas partagée.

## Commits

- **Atomiques** : un commit = un changement cohérent qui passe les tests. Ne pas
  mélanger refacto, formatage et fonctionnalité.
- **Message en français, verbe à l'infinitif**, ≤ 72 caractères, sans point final :
  - `Ajouter le statut de publication aux articles`
  - `Corriger le double envoi de l'email de bienvenue`
  - `Mettre à jour Rails en 8.1.4`
- Corps (optionnel, après une ligne vide) : **pourquoi** le changement, contexte,
  ticket. Le *quoi* se lit dans le diff.
- Une migration est commitée avec le `db/schema.rb` correspondant et le code qui
  l'utilise.

## Ne jamais commiter

- `.env`, `.env.local`, `config/master.key`, `config/credentials/*.key`
- Dumps de base, exports clients, fichiers contenant des données personnelles
- `.claude/settings.local.json` (réglages personnels)
- Fichiers générés (`app/assets/builds/*`, `log/`, `tmp/`, `storage/`)

Si un secret a été commité : le signaler immédiatement — il doit être révoqué et
régénéré, le supprimer de l'historique ne suffit pas.

## Pull requests

- Titre = résumé du changement (même style que les commits).
- Description : **contexte / pourquoi**, ce qui change, comment tester (parcours,
  compte de test), captures d'écran pour tout changement visuel, migrations ou
  variables d'env à ajouter au déploiement.
- PR petite et relisible ; si elle dépasse ~400 lignes hors fichiers générés, la
  découper.
- `bin/ci` vert avant de demander une relecture.
- **À COMPLÉTER selon le projet** : stratégie de merge (squash / merge commit),
  relecteurs, déploiement automatique ou non de `main` / `staging`.
