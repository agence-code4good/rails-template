# Template Rails 8.1 — Tailwind CSS v4 ou Bootstrap 5

Template de démarrage pour applications Rails, maintenu par l'agence.

## Stack

| Couche           | Choix                                                       | Pourquoi                                          |
| ---------------- | ----------------------------------------------------------- | ------------------------------------------------- |
| Ruby             | 4.0.7                                                       |                                                   |
| Rails            | 8.1.4                                                       |                                                   |
| Base de données  | PostgreSQL                                                  |                                                   |
| Asset pipeline   | **Propshaft**                                               | Défaut Rails 8, plus simple, pas de preprocessing |
| CSS              | **Tailwind CSS v4** ou **Bootstrap 5** (au choix)           | Voir options ci-dessous                           |
| JavaScript       | **Importmap + Stimulus + Turbo** (Hotwire)                  | Défaut Rails 8, pas de Node requis                |
| Authentification | Devise (optionnel)                                          |                                                   |
| Autorisation     | Pundit                                                      |                                                   |
| Décorateurs      | **Draper**                                                  | `ApplicationDecorator` + `delegate_all`, helpers via `h` |
| IA               | **Claude Code**                                             | `CLAUDE.md` + skills projet (voir plus bas)       |
| Formulaires      | Simple Form                                                 | Wrappers Tailwind ou Bootstrap selon le choix     |
| Rate limiting    | Rack::Attack                                                |                                                   |
| Emails dev       | Letter Opener                                               |                                                   |

## Usage

Prérequis : Ruby 4.0.7+ et Rails 8.1.4+ (un avertissement s'affiche sinon).

```bash
rbenv install 4.0.7 && rbenv shell 4.0.7
gem install rails -v 8.1.4

rails new MON_APP --database=postgresql -m /chemin/vers/complete.rb
# ou en distant :
rails new MON_APP --database=postgresql -m https://raw.githubusercontent.com/agence-code4good/rails-template/main/complete.rb
```

> **Scalingo / Heroku (sans Kamal ni Docker)** — Rails 8 génère des fichiers Kamal et Docker par défaut. Si le déploiement se fait sur une plateforme PaaS, passer ces flags pour ne pas les générer :
>
> ```bash
> rails new MON_APP --database=postgresql --skip-kamal --skip-docker -m https://raw.githubusercontent.com/agence-code4good/rails-template/main/complete.rb
> ```

## Options interactives

Cinq questions sont posées au lancement :

| Option          | Choix / Ce qu'elle installe                                                                                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **CSS**         | `[1]` Tailwind CSS v4 via `tailwindcss-rails` (CSS-first, pas de Node) — `[2]` Bootstrap 5 via `dartsass-rails` + gem `bootstrap`                                  |
| **DaisyUI**     | *(si Tailwind)* Plugin composants UI v5. Télécharge `daisyui.mjs` en local (sans Node), ajoute `@plugin "./daisyui.mjs"` dans le CSS.                              |
| **Devise**      | Authentification utilisateur avec modèle `User` (boolean `admin`), sessions controller, vues stylisées.                                                             |
| **ActiveAdmin** | *(si Devise)* Interface d'administration CRUD. Compatible Propshaft via `activeadmin_assets`.                                                                       |
| **Email prod**  | `[1]` Postmark (`POSTMARK_API_TOKEN`) — `[2]` Brevo SMTP (`BREVO_LOGIN` + `BREVO_SMTP_KEY`) — `[3]` Aucun (configurer plus tard)                                   |

## Structure générée

```
app/
├── assets/tailwind/
│   ├── application.css            # @import tailwindcss + @theme + @plugin daisyui + @layer components
│   ├── daisyui.mjs                # (si DaisyUI activé) plugin téléchargé localement
│   └── daisyui-theme.mjs          # (si DaisyUI activé) thèmes téléchargés localement
├── controllers/
│   ├── application_controller.rb  # Pundit + authenticate_user!
│   ├── errors_controller.rb       # Pages 404/422/500
│   ├── pages_controller.rb        # Page d'accueil publique
│   └── users/
│       └── sessions_controller.rb # Hook CAPTCHA commenté
├── helpers/
│   └── application_helper.rb      # svg_tag, turbo_stream_flash, SEO helpers
├── javascript/controllers/
│   ├── navbar_controller.js       # Toggle menu mobile
│   └── flash_controller.js        # Auto-dismiss après 5s
├── decorators/
│   ├── application_decorator.rb   # Base Draper (delegate_all)
│   └── user_decorator.rb          # (si Devise) Exemple : display_name, role_label
├── policies/
│   ├── application_policy.rb      # Base Pundit
│   └── admin_policy.rb            # Politique admin
└── views/
    ├── devise/                    # Toutes les vues en Tailwind
    ├── errors/                    # 404, 422, 500
    ├── layouts/application.html.erb
    ├── pages/home.html.erb
    └── shared/
        ├── _navbar.html.erb
        ├── _flashes.html.erb
        └── _footer.html.erb
config/
├── environments/staging.rb        # require_relative "production" + surcharges
├── initializers/
│   ├── devise.rb
│   ├── rack_attack.rb
│   └── simple_form.rb             # Wrappers Tailwind
└── locales/
    ├── devise.fr.yml
    └── fr.yml
```

## Palette de couleurs

Définie via `@theme` dans `application.tailwind.css` (Tailwind v4 CSS-first) :

```css
@theme {
  --color-brand-blue: #344054;
  --color-brand-grey: #475467;
  --color-brand-green: #044827;
}
```

Disponible directement comme classes Tailwind :

```
text-brand-blue   bg-brand-blue   border-brand-blue
text-brand-grey
text-brand-green  bg-brand-green  border-brand-green
```

## Composants CSS (`@layer components`)

| Classe           | Usage                               |
| ---------------- | ----------------------------------- |
| `.btn-primary`   | Bouton principal (fond vert)        |
| `.btn-secondary` | Bouton secondaire (contour bleu)    |
| `.btn-danger`    | Bouton destructif (fond rouge)      |
| `.form-input`    | Champ de formulaire                 |
| `.form-label`    | Label de formulaire                 |
| `.card`          | Carte blanche avec bordure et ombre |

## Simple Form — wrappers disponibles

| Wrapper        | Usage                                    |
| -------------- | ---------------------------------------- |
| `:default`     | Champ standard (utilisé automatiquement) |
| `:check_boxes` | Cases à cocher                           |
| `:inline`      | Champ inline (ex: recherche)             |

## Variables d'environnement

Copier `.env.example` → `.env` :

```bash
cp .env.example .env
```

Variables obligatoires en production :

```
APP_NAME=
APP_HOST=
MAILER_SENDER=
DATABASE_URL=          # ou credentials Rails
POSTMARK_API_TOKEN=    # si Postmark activé
```

## Environnement staging

`config/environments/staging.rb` est généré automatiquement : il charge `production.rb` (mailer compris) puis surcharge le niveau de log, `force_ssl` et l'hôte des emails. Toute modification de la prod s'applique donc aussi au staging.

Créer les credentials staging :

```bash
bin/rails credentials:edit --environment staging
```

## Compte de développement (seeds)

```
Email    : dev@example.com
Password : devpassword123!
Admin    : true
```

Changer ces valeurs avant tout déploiement.

## Rake / commandes utiles

```bash
bin/dev                     # Serveur + Tailwind watcher
bin/rails db:seed           # Créer le compte dev
bin/rails tailwindcss:build # Build CSS one-shot
```

## Décorateurs (Draper)

Usage dans un controller :

```ruby
@user  = User.find(params[:id]).decorate
@users = User.all.decorate            # collection (relation ActiveRecord)
# ou explicitement
@user  = UserDecorator.decorate(user)
@users = UserDecorator.decorate_collection(users)
```

Pour créer un nouveau décorateur :

```ruby
# app/decorators/post_decorator.rb
class PostDecorator < ApplicationDecorator
  def formatted_date
    h.l(created_at, format: :long)
  end
end
```

> `bin/rails g decorator Post` génère directement `< ApplicationDecorator` (template surchargé dans `lib/templates/rails/decorator/decorator.rb.tt`).
> `delegate_all` est déjà déclaré dans `ApplicationDecorator`, inutile de le répéter.
> Le hook Draper sur `g controller` est désactivé (`g.decorator false`) : pas de décorateur vide créé à chaque controller.

## Claude Code

Le template génère un setup Claude Code adapté aux options choisies (sources dans [`claude/`](claude/), fichiers `.tt` = templates ERB) :

```
CLAUDE.md                              # stack réelle, commandes, où trouver quoi, règles
.claude/
├── settings.json                      # permissions (bin/rails g, bin/ci, git status…) + secrets interdits en lecture
└── skills/
    ├── projet/
    │   ├── SKILL.md                   # À COMPLÉTER : client, rôles, glossaire, modèle de données, décisions…
    │   └── charte-ui.md               # À COMPLÉTER : charte graphique, tokens, procédure d'intégration
    ├── conventions-rails/SKILL.md     # conventions de code Rails 8.1 de l'agence
    ├── nouvelle-feature/SKILL.md      # déroulé pour ajouter une ressource de bout en bout
    └── git/SKILL.md                   # branches, commits, PR, règles de prudence
```

**Au démarrage d'un projet** : compléter le résumé de `CLAUDE.md` et les sections « À COMPLÉTER » du skill `projet`. Dès qu'une charte est fournie, déposer les sources dans `docs/charte/` et demander à Claude de l'intégrer (la procédure est dans `charte-ui.md`).

`.claude/settings.local.json` (réglages perso) est ignoré par git.

## Notes de compatibilité

- **Tailwind v4** : configuration CSS-first. Pas de `tailwind.config.js`. La customisation se fait via `@theme` et `@plugin` dans le CSS.
- **DaisyUI v5** : compatible Tailwind v4. Installé sans Node via `curl` (fichiers `.mjs` locaux dans `app/assets/tailwind/`). Méthode officielle : https://daisyui.com/docs/install/rails/
- **Bootstrap 5** : via `dartsass-rails` + gem `bootstrap`. Compilation SASS sans Node. Bootstrap JS disponible via importmap (`bootstrap.bundle` incl. Popper). Simple Form configuré avec `--bootstrap`.
- **Brevo** : pas de gem, configuration SMTP native ActionMailer. Variables : `BREVO_LOGIN` (votre login Brevo) et `BREVO_SMTP_KEY` (clé SMTP dans Brevo > SMTP & API).
- **ActiveAdmin** : version **4 (beta)** — `activeadmin_assets` (compatibilité Propshaft) exige `activeadmin >= 4.0.0.beta22`. Autorisation via `AdminPolicy` (tous les droits pour `user.admin?`) ; refus → `ApplicationController#access_denied`.
- **Navigateurs** : `allow_browser versions: :modern` (défaut Rails 8) est commenté dans `ApplicationController` pour ne pas exclure les navigateurs anciens. Le décommenter si le public du projet le permet.
- **Rack::Attack** : compteurs stockés dans `Rails.cache` (Solid Cache en prod), partagés entre workers. En dev, le cache est un `null_store` sauf après `bin/rails dev:cache` : le throttling n'y est donc pas actif.
- **Statut 422** : utiliser `:unprocessable_content` (`:unprocessable_entity` est déprécié depuis Rack 3.1).
