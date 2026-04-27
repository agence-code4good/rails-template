# Template Rails 8.1 — Tailwind CSS v4 ou Bootstrap 5

Template de démarrage pour applications Rails, maintenu par l'agence.

## Stack

| Couche           | Choix                                                       | Pourquoi                                          |
| ---------------- | ----------------------------------------------------------- | ------------------------------------------------- |
| Ruby             | 3.3.5                                                       |                                                   |
| Rails            | 8.1.3                                                       |                                                   |
| Base de données  | PostgreSQL                                                  |                                                   |
| Asset pipeline   | **Propshaft**                                               | Défaut Rails 8, plus simple, pas de preprocessing |
| CSS              | **Tailwind CSS v4** ou **Bootstrap 5** (au choix)           | Voir options ci-dessous                           |
| JavaScript       | **Importmap + Stimulus + Turbo** (Hotwire)                  | Défaut Rails 8, pas de Node requis                |
| Authentification | Devise (optionnel)                                          |                                                   |
| Autorisation     | Pundit                                                      |                                                   |
| Décorateurs      | **PORO Decorators** (sans gem)                              | `ApplicationDecorator` + `delegate_missing_to`    |
| Formulaires      | Simple Form                                                 | Wrappers Tailwind ou Bootstrap selon le choix     |
| Rate limiting    | Rack::Attack                                                |                                                   |
| Emails dev       | Letter Opener                                               |                                                   |

## Usage

```bash
rails new MON_APP --database=postgresql -m /chemin/vers/complete.rb
# ou en distant :
rails new MON_APP --database=postgresql -m https://raw.githubusercontent.com/.../complete.rb
```

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
│   ├── application_decorator.rb   # Base PORO (delegate_missing_to + view context)
│   └── user_decorator.rb          # Exemple : display_name, role_label
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
├── environments/staging.rb
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

Copier le fichier de référence :

```bash
cp config/staging.rb config/environments/staging.rb
```

Puis créer les credentials staging :

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

## PORO Decorators

Usage dans un controller ou une vue :

```ruby
# Controller
@user = decorate(User.find(params[:id]))
# ou
@user = UserDecorator.decorate(User.find(params[:id]), view_context)

# Collection
@users = UserDecorator.decorate_collection(User.all, view_context)
```

Pour créer un nouveau décorateur :

```ruby
# app/decorators/post_decorator.rb
class PostDecorator < ApplicationDecorator
  def formatted_date
    view.l(created_at, format: :long)
  end
end
```

## Notes de compatibilité

- **Tailwind v4** : configuration CSS-first. Pas de `tailwind.config.js`. La customisation se fait via `@theme` et `@plugin` dans le CSS.
- **DaisyUI v5** : compatible Tailwind v4. Installé sans Node via `curl` (fichiers `.mjs` locaux dans `app/assets/tailwind/`). Méthode officielle : https://daisyui.com/docs/install/rails/
- **Bootstrap 5** : via `dartsass-rails` + gem `bootstrap`. Compilation SASS sans Node. Bootstrap JS disponible via importmap (`bootstrap.bundle` incl. Popper). Simple Form configuré avec `--bootstrap`.
- **Brevo** : pas de gem, configuration SMTP native ActionMailer. Variables : `BREVO_LOGIN` (votre login Brevo) et `BREVO_SMTP_KEY` (clé SMTP dans Brevo > SMTP & API).
- **ActiveAdmin** : compatible Propshaft via `activeadmin_assets`.
