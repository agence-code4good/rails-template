# =============================================================================
# Template Rails 8.1 — Tailwind CSS + Hotwire
# =============================================================================
#
# Usage local :
#   rails new MY_APP --database=postgresql -m /chemin/vers/complete.rb
#
# Usage distant (repo public uniquement) :
#   rails new MY_APP --database=postgresql \
#     -m https://raw.githubusercontent.com/agence-code4good/rails-template/main/complete.rb
#
# Prérequis :
#   ruby 3.3.5+, rails 8.1+

TEMPLATE_REPO = "https://raw.githubusercontent.com/agence-code4good/rails-template/main"
#
# Ce que ça installe :
#   - Tailwind CSS v4 (via tailwindcss-rails, propshaft, importmap)
#   - Devise (authentification)
#   - Pundit (autorisation)
#   - PORO Decorators (ApplicationDecorator sans gem)
#   - Simple Form (formulaires)
#   - Rack::Attack (rate limiting)
#   - Letter Opener (emails en dev)
#   - [Optionnel] DaisyUI
#   - [Optionnel] ActiveAdmin
#   - [Optionnel] Postmark
# =============================================================================

# =============================================================================
# OPTIONS INTERACTIVES
# =============================================================================

puts "\n#{"=" * 60}"
puts "   Template Rails 8.1 + Tailwind CSS"
puts "=" * 60

use_devise       = yes?("→ Installer Devise (authentification) ? [y/N] ")
use_daisyui      = yes?("→ Installer DaisyUI ? (composants Tailwind) [y/N] ")
use_active_admin = use_devise && yes?("→ Installer ActiveAdmin ? [y/N] ")
use_postmark     = yes?("→ Utiliser Postmark pour les emails ? [y/N] ")

puts "\nConfiguration :"
puts "  Devise       : #{use_devise ? "✓" : "✗"}"
puts "  DaisyUI      : #{use_daisyui ? "✓" : "✗"}"
puts "  ActiveAdmin  : #{use_active_admin ? "✓" : "✗"}"
puts "  Postmark     : #{use_postmark ? "✓" : "✗"}"
puts "=" * 60

# =============================================================================
# GEMFILE
# =============================================================================

# Nettoyer les gems Bootstrap / Sass inutiles si présentes
gsub_file "Gemfile", /^gem ["']sass-rails["'].*\n/, ""
gsub_file "Gemfile", /^gem ["']bootstrap["'].*\n/, ""
gsub_file "Gemfile", /^gem ["']cssbundling-rails["'].*\n/, ""

# CSS — Tailwind via binaire standalone (pas de Node requis pour le JS)
gem "tailwindcss-rails"

# Authentification
gem "devise" if use_devise

# Autorisation
gem "pundit"

# Formulaires
gem "simple_form"

# Sécurité
gem "rack-attack"

# Emails développement
gem "letter_opener", group: :development

# Emails production (optionnel)
gem "postmark-rails" if use_postmark

# Admin (optionnel)
# activeadmin_assets rend ActiveAdmin compatible avec Propshaft (assets pré-compilés)
if use_active_admin
  gem "activeadmin"
  gem "activeadmin_assets"
end

# =============================================================================
# AFTER BUNDLE
# =============================================================================

after_bundle do
  # ---------------------------------------------------------------------------
  # CONFIGURATION APPLICATION
  # ---------------------------------------------------------------------------

  # Copie des images placeholder (fonctionne en local et en distant)
  # En local  : copy_file depuis __dir__
  # En distant : get depuis raw.githubusercontent.com (repo doit être public)
  if File.exist?(File.join(__dir__, "images/logo.svg"))
    source_paths.unshift(__dir__)
    copy_file "images/logo.svg",   "app/assets/images/logo.svg"
    copy_file "images/banner.svg", "app/assets/images/banner.svg"
  else
    get "#{TEMPLATE_REPO}/images/logo.svg",   "app/assets/images/logo.svg"
    get "#{TEMPLATE_REPO}/images/banner.svg", "app/assets/images/banner.svg"
  end
  say "\n💡 Remplace app/assets/images/logo.svg et banner.svg par les assets du projet.", :cyan

  # Locale française par défaut
  environment 'config.i18n.default_locale = :fr'
  environment 'config.i18n.available_locales = [:fr, :en]'

  # Générateurs allégés (pas de helpers, assets, tests auto-générés)
  environment <<~RUBY
    config.generators do |g|
      g.assets false
      g.helper false
      g.test_framework nil
    end
  RUBY

  # Gestion d'erreurs via les routes (pages d'erreur personnalisées)
  environment 'config.exceptions_app = self.routes'

  # ---------------------------------------------------------------------------
  # TAILWIND CSS
  # ---------------------------------------------------------------------------

  rails_command "tailwindcss:install"

  # DaisyUI v5 — sans Node : téléchargement des fichiers .mjs en local
  # Méthode officielle Rails : https://daisyui.com/docs/install/rails/
  if use_daisyui
    run "curl -sLo app/assets/tailwind/daisyui.mjs https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.mjs"
    run "curl -sLo app/assets/tailwind/daisyui-theme.mjs https://github.com/saadeghi/daisyui/releases/latest/download/daisyui-theme.mjs"
  end

  # CSS applicatif — Tailwind v4 (CSS-first, pas de tailwind.config.js)
  # La configuration se fait directement dans le CSS via @theme et @plugin
  create_file "app/assets/tailwind/application.css", force: true do
    daisyui_lines = use_daisyui ? <<~DAISY : ""

      @source not "./daisyui{,*}.mjs";
      @plugin "./daisyui.mjs";
      @plugin "./daisyui-theme.mjs";
    DAISY

    <<~CSS
      @import "tailwindcss";
      #{daisyui_lines}

      @theme {
        --font-family-sans: 'Inter var', ui-sans-serif, system-ui, sans-serif;
        --color-brand-blue:  #344054;
        --color-brand-grey:  #475467;
        --color-brand-green: #044827;
      }

      @layer base {
        html {
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
        }
      }

      @layer components {
        .btn-primary {
          @apply inline-flex items-center justify-center bg-brand-green text-white font-semibold py-3 px-6 rounded-lg hover:opacity-90 transition-opacity duration-200 cursor-pointer;
        }

        .btn-secondary {
          @apply inline-flex items-center justify-center bg-white text-brand-blue border border-brand-blue font-semibold py-3 px-6 rounded-lg hover:bg-slate-50 transition-colors duration-200 cursor-pointer;
        }

        .btn-danger {
          @apply inline-flex items-center justify-center bg-red-600 text-white font-semibold py-3 px-6 rounded-lg hover:bg-red-700 transition-colors duration-200 cursor-pointer;
        }

        .form-input {
          @apply w-full rounded-lg border border-slate-300 text-brand-blue placeholder-slate-400 px-3 py-2 focus:outline-none focus:border-brand-green focus:ring-1 focus:ring-brand-green transition-colors;
        }

        .form-label {
          @apply block text-sm font-medium text-brand-blue mb-1;
        }

        .form-hint {
          @apply mt-1 text-xs text-slate-500;
        }

        .form-error {
          @apply mt-1 text-xs text-red-600;
        }

        .card {
          @apply bg-white rounded-xl border border-slate-100 shadow-sm p-6;
        }
      }
    CSS
  end

  # ---------------------------------------------------------------------------
  # STIMULUS CONTROLLERS
  # ---------------------------------------------------------------------------

  # Controller navbar : toggle menu mobile
  create_file "app/javascript/controllers/navbar_controller.js" do
    <<~JS
      import { Controller } from "@hotwired/stimulus"

      export default class extends Controller {
        static targets = ["menu"]

        toggleMenu() {
          this.menuTarget.classList.toggle("hidden")
        }

        closeMenu() {
          this.menuTarget.classList.add("hidden")
        }
      }
    JS
  end

  # Controller flash : auto-dismiss après 5s
  create_file "app/javascript/controllers/flash_controller.js" do
    <<~JS
      import { Controller } from "@hotwired/stimulus"

      export default class extends Controller {
        connect() {
          this.timeout = setTimeout(() => this.dismiss(), 5000)
        }

        disconnect() {
          clearTimeout(this.timeout)
        }

        dismiss() {
          this.element.style.transition = "opacity 0.3s ease, transform 0.3s ease"
          this.element.style.opacity = "0"
          this.element.style.transform = "translateY(4px)"
          setTimeout(() => this.element.remove(), 300)
        }
      }
    JS
  end

  # Enregistrer les nouveaux controllers dans le manifest Stimulus
  # Le fichier index.js est créé par tailwindcss:install ou stimulus:install
  stimulus_index = "app/javascript/controllers/index.js"
  if File.exist?(stimulus_index)
    append_to_file stimulus_index do
      <<~JS

        import NavbarController from "./navbar_controller"
        application.register("navbar", NavbarController)

        import FlashController from "./flash_controller"
        application.register("flash", FlashController)
      JS
    end
  else
    # Rails 8 : les controllers sont auto-chargés via eagerLoadControllersFrom
    # Rien à faire, les fichiers dans controllers/ sont détectés automatiquement
    say "ℹ️  Stimulus controllers auto-chargés (pas d'index.js détecté).", :blue
  end

  # ---------------------------------------------------------------------------
  # DEVISE (optionnel)
  # ---------------------------------------------------------------------------

  if use_devise
    generate "devise:install"

    remove_file "config/initializers/devise.rb"
    create_file "config/initializers/devise.rb" do
      <<~RUBY
        # frozen_string_literal: true

        Devise.setup do |config|
          config.mailer_sender = ENV.fetch("MAILER_SENDER", "noreply@example.com")

          require "devise/orm/active_record"

          config.case_insensitive_keys = [:email]
          config.strip_whitespace_keys = [:email]
          config.skip_session_storage = [:http_auth]
          config.stretches = Rails.env.test? ? 1 : 12
          config.reconfirmable = true
          config.expire_all_remember_me_on_sign_out = true
          config.password_length = 8..128
          config.email_regexp = /\\A[^@\\s]+@[^@\\s]+\\z/
          config.reset_password_within = 6.hours
          config.sign_out_via = :delete

          # Réponses HTTP correctes (Rails 8)
          config.responder.error_status = :unprocessable_entity
          config.responder.redirect_status = :see_other

          # Verrouillage après tentatives échouées
          config.lock_strategy = :failed_attempts
          config.unlock_keys = [:email]
          config.unlock_strategy = :time
          config.maximum_attempts = 5
          config.unlock_in = 1.hour
          config.last_attempt_warning = true
        end
      RUBY
    end

    generate "devise", "User"

    # Remplacer la ligne devise_for générée automatiquement pour y ajouter
    # notre sessions controller personnalisé (évite une double déclaration)
    gsub_file "config/routes.rb",
      /devise_for :users\b.*/,
      'devise_for :users, controllers: { sessions: "users/sessions" }'

    # Ajouter colonne admin dans la migration Devise
    devise_migration = Dir["db/migrate/*_devise_create_users.rb"].first
    if devise_migration
      gsub_file devise_migration, /(\s*t\.timestamps.*\n)/, "\\1      t.boolean :admin, null: false, default: false\n"
    end

    # Activer :lockable dans le modèle User
    gsub_file "app/models/user.rb",
      ":validatable",
      ":validatable, :lockable"

    inject_into_file "app/models/user.rb", after: "class User < ApplicationRecord\n" do
      "  # Rôles\n  scope :admins, -> { where(admin: true) }\n\n"
    end
  end

  # ---------------------------------------------------------------------------
  # PUNDIT
  # ---------------------------------------------------------------------------

  generate "pundit:install"

  # Policy admin de base
  create_file "app/policies/admin_policy.rb" do
    <<~RUBY
      # frozen_string_literal: true

      class AdminPolicy < ApplicationPolicy
        def index?
          user&.admin?
        end
      end
    RUBY
  end

  # ---------------------------------------------------------------------------
  # PORO DECORATORS (sans gem)
  # ---------------------------------------------------------------------------

  # Classe de base : délègue au modèle via method_missing + expose le view context
  create_file "app/decorators/application_decorator.rb" do
    <<~RUBY
      # frozen_string_literal: true

      class ApplicationDecorator
        delegate_missing_to :@object

        def initialize(object, view_context = nil)
          @object = object
          @view   = view_context
        end

        def self.decorate(object, view_context = nil)
          new(object, view_context)
        end

        def self.decorate_collection(collection, view_context = nil)
          collection.map { |obj| new(obj, view_context) }
        end

        private

        attr_reader :object, :view
      end
    RUBY
  end

  # Exemple : UserDecorator
  create_file "app/decorators/user_decorator.rb" do
    <<~RUBY
      # frozen_string_literal: true

      class UserDecorator < ApplicationDecorator
        def display_name
          email.split("@").first.capitalize
        end

        def role_label
          admin? ? "Admin" : "Utilisateur"
        end
      end
    RUBY
  end

  # Helper pour décorer facilement depuis les controllers et views
  inject_into_file "app/helpers/application_helper.rb", after: "module ApplicationHelper\n" do
    <<~RUBY
      def decorate(object, decorator_class = nil)
        klass = decorator_class || "\#{object.class.name}Decorator".constantize
        klass.decorate(object, self)
      rescue NameError
        object
      end

    RUBY
  end

  # ---------------------------------------------------------------------------
  # SIMPLE FORM — configuration Tailwind
  # ---------------------------------------------------------------------------

  generate "simple_form:install"

  remove_file "config/initializers/simple_form.rb"
  create_file "config/initializers/simple_form.rb" do
    <<~RUBY
      # frozen_string_literal: true

      SimpleForm.setup do |config|
        # Wrapper par défaut : Tailwind
        config.wrappers :default, class: "mb-4" do |b|
          b.use :html5
          b.use :placeholder
          b.optional :maxlength
          b.optional :minlength
          b.optional :pattern
          b.optional :min_max
          b.optional :readonly
          b.use :label, class: "form-label"
          b.use :input,
                class: "form-input",
                error_class: "form-input !border-red-500 !ring-red-500"
          b.use :full_error, wrap_with: { tag: :p, class: "form-error" }
          b.use :hint,       wrap_with: { tag: :p, class: "form-hint" }
        end

        # Wrapper pour les checkboxes
        config.wrappers :check_boxes, tag: :div, class: "mb-4 flex items-center gap-2" do |b|
          b.use :html5
          b.use :input, class: "rounded border-slate-300 text-brand-green focus:ring-brand-green"
          b.use :label, class: "text-sm text-brand-blue"
          b.use :full_error, wrap_with: { tag: :p, class: "form-error" }
          b.use :hint,       wrap_with: { tag: :p, class: "form-hint" }
        end

        # Wrapper inline (ex: formulaire de recherche)
        config.wrappers :inline, class: "flex items-center gap-2" do |b|
          b.use :html5
          b.use :label, class: "form-label mb-0 shrink-0"
          b.use :input, class: "form-input"
          b.use :full_error, wrap_with: { tag: :p, class: "form-error" }
        end

        config.default_wrapper      = :default
        config.button_class         = "btn-primary"
        config.required_by_default  = true
        config.browser_validations  = false
        config.boolean_label_class  = "text-sm text-brand-blue"
        config.label_text           = lambda { |label, _req, _explicit| label }
      end
    RUBY
  end

  # ---------------------------------------------------------------------------
  # RACK::ATTACK — rate limiting
  # ---------------------------------------------------------------------------

  create_file "config/initializers/rack_attack.rb" do
    <<~RUBY
      # frozen_string_literal: true

      class Rack::Attack
        Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

        # Throttle général : 1000 req / 5 min par IP
        throttle("req/ip", limit: 1_000, period: 5.minutes) do |req|
          req.ip unless req.path.start_with?("/assets")
        end

        # Throttle connexions par IP : 5 tentatives / 20s
        throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
          req.ip if req.path == "/users/sign_in" && req.post?
        end

        # Throttle connexions par email : 5 tentatives / 20s
        throttle("logins/email", limit: 5, period: 20.seconds) do |req|
          if req.path == "/users/sign_in" && req.post?
            req.params.dig("user", "email")&.downcase&.gsub(/\\s+/, "")
          end
        end

        # Réponse 429 personnalisée
        self.throttled_responder = lambda do |_request|
          [429, { "Content-Type" => "text/plain" }, ["Trop de requêtes. Réessayez dans quelques instants."]]
        end
      end
    RUBY
  end

  # ---------------------------------------------------------------------------
  # ACTIVE ADMIN (optionnel)
  # ---------------------------------------------------------------------------

  if use_active_admin
    generate "active_admin:install", "--skip-users"

    remove_file "config/initializers/active_admin.rb"
    create_file "config/initializers/active_admin.rb" do
      <<~RUBY
        # frozen_string_literal: true

        ActiveAdmin.setup do |config|
          config.site_title = ENV.fetch("APP_NAME", "#{app_name.split("_").map(&:capitalize).join(" ")} Admin")

          config.authentication_method = :authenticate_admin!
          config.current_user_method   = :current_user
          config.logout_link_path      = :destroy_user_session_path
          config.logout_link_method    = :delete

          config.authorization_adapter    = ActiveAdmin::PunditAdapter
          config.pundit_default_policy    = "AdminPolicy"
          config.on_unauthorized_access   = :access_denied

          config.batch_actions     = true
          config.filter_attributes = [:encrypted_password, :password, :password_confirmation]
          config.localize_format   = :long
        end
      RUBY
    end

    # Méthode authenticate_admin! dans ApplicationController (injectée après setup)
  end

  # ---------------------------------------------------------------------------
  # APPLICATION CONTROLLER
  # ---------------------------------------------------------------------------

  remove_file "app/controllers/application_controller.rb"
  create_file "app/controllers/application_controller.rb" do
    admin_method = if use_active_admin
      <<~RUBY

          # Utilisé par ActiveAdmin
          def authenticate_admin!
            unless current_user&.admin?
              flash[:alert] = I18n.t("errors.unauthorized")
              redirect_to root_path
            end
          end
      RUBY
    else
      ""
    end

    authenticate_line   = use_devise ? "\n        before_action :authenticate_user!\n" : ""
    pundit_rescue_line  = "\n        rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized\n"
    sign_in_out_methods = use_devise ? <<~RUBY : ""

        def after_sign_in_path_for(_resource)
          root_path
        end

        def after_sign_out_path_for(_resource_or_scope)
          new_user_session_path
        end
    RUBY

    <<~RUBY
      # frozen_string_literal: true

      class ApplicationController < ActionController::Base
        include Pundit::Authorization

        protect_from_forgery with: :exception
      #{authenticate_line}#{pundit_rescue_line}
      #{admin_method}
        private

        def user_not_authorized
          flash[:alert] = I18n.t("errors.unauthorized")
          redirect_back_or_to root_path
        end
      #{sign_in_out_methods}
      end
    RUBY
  end

  # ---------------------------------------------------------------------------
  # ERRORS CONTROLLER
  # ---------------------------------------------------------------------------

  create_file "app/controllers/errors_controller.rb" do
    <<~RUBY
      # frozen_string_literal: true

      class ErrorsController < ApplicationController
        #{"skip_before_action :authenticate_user!" if use_devise}

        def not_found
          render status: :not_found
        end

        def unprocessable
          render status: :unprocessable_entity
        end

        def internal_server_error
          render status: :internal_server_error
        end
      end
    RUBY
  end

  # ---------------------------------------------------------------------------
  # PAGES CONTROLLER
  # ---------------------------------------------------------------------------

  generate :controller, "pages", "home", "--skip-routes", "--no-helper"

  remove_file "app/controllers/pages_controller.rb"
  create_file "app/controllers/pages_controller.rb" do
    <<~RUBY
      # frozen_string_literal: true

      class PagesController < ApplicationController
        #{"skip_before_action :authenticate_user!" if use_devise}

        def home
        end
      end
    RUBY
  end

  # Sessions controller Devise (avec hook CAPTCHA commenté)
  if use_devise
  create_file "app/controllers/users/sessions_controller.rb" do
    <<~RUBY
      # frozen_string_literal: true

      class Users::SessionsController < Devise::SessionsController
        # prepend_before_action :check_captcha, only: [:create]

        def create
          super
        end

        private

        # Pour activer reCAPTCHA, décommenter la ligne ci-dessus et configurer :
        # gem "recaptcha"
        # ENV["RECAPTCHA_SITE_KEY"] et ENV["RECAPTCHA_SECRET_KEY"]
        def check_captcha
          unless verify_recaptcha(secret_key: ENV["RECAPTCHA_SECRET_KEY"])
            self.resource = resource_class.new sign_in_params
            respond_with_navigational(resource) do
              flash[:alert] = I18n.t("devise.sessions.captcha_failed")
              render :new
            end
          end
        end
      end
    RUBY
  end
  end # use_devise

  # ---------------------------------------------------------------------------
  # APPLICATION HELPER
  # ---------------------------------------------------------------------------

  remove_file "app/helpers/application_helper.rb"
  create_file "app/helpers/application_helper.rb" do
    <<~RUBY
      # frozen_string_literal: true

      module ApplicationHelper
        # Inline SVG depuis app/assets/images/*.svg
        def svg_tag(name, **options)
          file_path = Rails.root.join("app/assets/images/\#{name}.svg")
          return "(svg not found: \#{name})" unless File.exist?(file_path)

          content = File.read(file_path)
          options.each { |k, v| content.sub!(/<svg/, "<svg \#{k}=\\\"\#{v}\\\"") }
          content.html_safe
        end

        # Turbo Stream flash (pour les actions Turbo)
        def render_turbo_stream_flash_messages
          turbo_stream.prepend "flash", partial: "shared/flashes"
        end

        # Helpers SEO
        def page_title(title = nil)
          app = ENV.fetch("APP_NAME", Rails.application.class.module_parent_name.titleize)
          title.present? ? "\#{title} | \#{app}" : app
        end

        def page_description(desc = nil)
          desc.presence || ENV.fetch("APP_DESCRIPTION", "")
        end
      end
    RUBY
  end

  # ---------------------------------------------------------------------------
  # LAYOUT APPLICATION
  # ---------------------------------------------------------------------------

  remove_file "app/views/layouts/application.html.erb"
  create_file "app/views/layouts/application.html.erb" do
    <<~ERB
      <!DOCTYPE html>
      <html lang="fr" class="h-full">
        <head>
          <title><%= content_for?(:meta_title) ? yield(:meta_title) : page_title %></title>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <meta name="description" content="<%= content_for?(:meta_description) ? yield(:meta_description) : page_description %>">
          <meta property="og:title" content="<%= content_for?(:meta_title) ? yield(:meta_title) : page_title %>">
          <meta property="og:description" content="<%= content_for?(:meta_description) ? yield(:meta_description) : page_description %>">
          <meta property="og:type" content="website">
          <%= csrf_meta_tags %>
          <%= csp_meta_tag %>
          <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
          <%= javascript_importmap_tags %>
        </head>

        <body class="h-full bg-white text-brand-blue antialiased">
          <% unless content_for?(:no_navbar) %>
            <%= render "shared/navbar" %>
          <% end %>

          <div id="flash"
               class="fixed top-20 right-4 z-50 w-96 max-w-[calc(100vw-2rem)] space-y-2 pointer-events-none">
            <%= render "shared/flashes" %>
          </div>

          <main class="<%= content_for?(:no_navbar) ? '' : 'pt-0' %>">
            <%= yield %>
          </main>

          <% unless content_for?(:no_footer) %>
            <%= render "shared/footer" %>
          <% end %>
        </body>
      </html>
    ERB
  end

  # ---------------------------------------------------------------------------
  # VUES PARTAGÉES
  # ---------------------------------------------------------------------------

  # Navbar
  create_file "app/views/shared/_navbar.html.erb" do
    if use_daisyui
      <<~ERB
        <div class="navbar fixed top-0 inset-x-0 z-40 bg-base-100 shadow-sm min-h-[70px]"
             data-controller="navbar">
          <div class="navbar-start">
            <%= link_to root_path, class: "btn btn-ghost gap-2" do %>
              <%= image_tag "logo.svg", class: "h-[50px] w-auto", alt: Rails.application.class.module_parent_name %>
            <% end %>
          </div>

          <div class="navbar-end hidden md:flex">
            <% if user_signed_in? %>
              <div class="dropdown dropdown-end">
                <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar placeholder">
                  <div class="bg-brand-green text-white rounded-full w-10 text-sm font-bold">
                    <%= current_user.email.first.upcase %>
                  </div>
                </div>
                <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-[1] mt-2 w-52 p-2 shadow-lg border border-base-200">
                  <li class="menu-title text-xs opacity-60 px-2 pb-1 truncate"><%= current_user.email %></li>
                  <li>
                    <%= link_to "Se déconnecter", destroy_user_session_path,
                        data: { turbo_method: :delete } %>
                  </li>
                </ul>
              </div>
            <% else %>
              <%= link_to "Se connecter", new_user_session_path, class: "btn btn-ghost text-sm" %>
            <% end %>
          </div>

          <!-- Hamburger mobile -->
          <div class="navbar-end md:hidden">
            <button class="btn btn-ghost btn-square" data-action="click->navbar#toggleMenu">
              <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Menu mobile -->
        <div class="hidden fixed top-[70px] inset-x-0 z-30 bg-base-100 shadow-lg border-t border-base-200 md:hidden"
             data-navbar-target="menu">
          <ul class="menu p-4 space-y-1">
            <% if user_signed_in? %>
              <li class="menu-title text-xs opacity-60 truncate"><%= current_user.email %></li>
              <li><%= link_to "Se déconnecter", destroy_user_session_path, data: { turbo_method: :delete } %></li>
            <% else %>
              <li><%= link_to "Se connecter", new_user_session_path %></li>
            <% end %>
          </ul>
        </div>

        <div class="h-[70px]"></div>
      ERB
    else
      <<~ERB
        <nav class="fixed top-0 inset-x-0 z-40 bg-white border-b border-slate-100 shadow-sm"
             data-controller="navbar">
          <div class="h-[70px] max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between">

            <!-- Logo -->
            <%= link_to root_path, class: "flex items-center gap-3 shrink-0" do %>
              <%= image_tag "logo.svg", class: "h-[50px] w-auto", alt: Rails.application.class.module_parent_name %>
            <% end %>

            <!-- Navigation desktop -->
            <div class="hidden md:flex items-center gap-4">
              <% if user_signed_in? %>
                <div class="relative group">
                  <button class="flex items-center gap-2 text-sm font-medium text-brand-blue hover:text-brand-green transition-colors px-3 py-2 rounded-lg hover:bg-slate-50">
                    <span class="w-8 h-8 rounded-full bg-brand-green text-white flex items-center justify-center text-xs font-bold">
                      <%= current_user.email.first.upcase %>
                    </span>
                    <span class="max-w-[160px] truncate"><%= current_user.email %></span>
                    <svg class="w-4 h-4 shrink-0 transition-transform duration-200 group-hover:rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                    </svg>
                  </button>
                  <div class="absolute right-0 top-full mt-1 w-52 bg-white rounded-xl shadow-lg border border-slate-100 invisible opacity-0 group-hover:visible group-hover:opacity-100 transition-all duration-200 origin-top-right">
                    <%= link_to "Se déconnecter", destroy_user_session_path,
                        data: { turbo_method: :delete },
                        class: "block px-4 py-3 text-sm text-brand-blue hover:bg-slate-50 rounded-xl transition-colors" %>
                  </div>
                </div>
              <% else %>
                <%= link_to "Se connecter", new_user_session_path,
                    class: "text-sm font-medium text-brand-blue hover:text-brand-green transition-colors px-4 py-2 rounded-lg hover:bg-slate-50" %>
              <% end %>
            </div>

            <!-- Hamburger mobile -->
            <button class="md:hidden p-2 rounded-lg text-brand-blue hover:bg-slate-100 transition-colors"
                    data-action="click->navbar#toggleMenu">
              <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
              </svg>
            </button>
          </div>

          <!-- Menu mobile -->
          <div class="hidden md:hidden absolute top-[70px] inset-x-0 bg-white border-t border-slate-100 shadow-lg"
               data-navbar-target="menu">
            <div class="max-w-7xl mx-auto px-4 py-3 space-y-1">
              <% if user_signed_in? %>
                <p class="text-xs text-brand-grey px-3 py-1 truncate"><%= current_user.email %></p>
                <%= link_to "Se déconnecter", destroy_user_session_path,
                    data: { turbo_method: :delete },
                    class: "block px-3 py-2 text-sm text-brand-blue hover:bg-slate-50 rounded-lg transition-colors" %>
              <% else %>
                <%= link_to "Se connecter", new_user_session_path,
                    class: "block px-3 py-2 text-sm text-brand-blue hover:bg-slate-50 rounded-lg transition-colors" %>
              <% end %>
            </div>
          </div>
        </nav>

        <div class="h-[70px]"></div>
      ERB
    end
  end

  # Flash messages
  create_file "app/views/shared/_flashes.html.erb" do
    if use_daisyui
      <<~ERB
        <% if notice %>
          <div class="alert alert-warning shadow-lg pointer-events-auto" data-controller="flash">
            <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <span class="text-sm flex-1"><%= notice %></span>
            <button class="btn btn-ghost btn-xs" data-action="click->flash#dismiss">✕</button>
          </div>
        <% end %>

        <% if alert %>
          <div class="alert alert-error shadow-lg pointer-events-auto" data-controller="flash">
            <svg class="w-5 h-5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <span class="text-sm flex-1"><%= alert %></span>
            <button class="btn btn-ghost btn-xs" data-action="click->flash#dismiss">✕</button>
          </div>
        <% end %>
      ERB
    else
      <<~ERB
        <% if notice %>
          <div class="flex items-start gap-3 bg-amber-50 border border-amber-200 text-amber-900 rounded-xl p-4 shadow-md pointer-events-auto"
               data-controller="flash">
            <svg class="w-5 h-5 shrink-0 mt-0.5 text-amber-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <p class="flex-1 text-sm"><%= notice %></p>
            <button class="shrink-0 text-amber-600 hover:text-amber-900 transition-colors"
                    data-action="click->flash#dismiss">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        <% end %>

        <% if alert %>
          <div class="flex items-start gap-3 bg-red-50 border border-red-200 text-red-900 rounded-xl p-4 shadow-md pointer-events-auto"
               data-controller="flash">
            <svg class="w-5 h-5 shrink-0 mt-0.5 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <p class="flex-1 text-sm"><%= alert %></p>
            <button class="shrink-0 text-red-600 hover:text-red-900 transition-colors"
                    data-action="click->flash#dismiss">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        <% end %>
      ERB
    end
  end

  # Footer
  create_file "app/views/shared/_footer.html.erb" do
    <<~ERB
      <footer class="border-t border-slate-100 py-8 mt-auto">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <p class="text-center text-sm text-slate-400">
            © <%= Date.current.year %> <%= ENV.fetch("APP_NAME", Rails.application.class.module_parent_name.titleize) %>
          </p>
        </div>
      </footer>
    ERB
  end

  # Page d'accueil
  remove_file "app/views/pages/home.html.erb"
  create_file "app/views/pages/home.html.erb" do
    <<~ERB
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <h1 class="text-4xl font-bold text-brand-blue mb-4">Bienvenue !</h1>
        <p class="text-brand-grey">Votre application Rails est prête.</p>
      </div>
    ERB
  end

  # Pages d'erreur
  {
    "not_found"            => { code: 404, title: "Page introuvable",   message: "La page que vous cherchez n'existe pas ou a été déplacée." },
    "unprocessable"        => { code: 422, title: "Requête invalide",    message: "Votre requête n'a pas pu être traitée." },
    "internal_server_error"=> { code: 500, title: "Erreur serveur",     message: "Une erreur inattendue s'est produite. Notre équipe a été notifiée." }
  }.each do |action, info|
    create_file "app/views/errors/#{action}.html.erb" do
      <<~ERB
        <%= content_for :no_navbar, true %>
        <%= content_for :no_footer, true %>

        <div class="min-h-screen flex items-center justify-center px-4">
          <div class="text-center max-w-md">
            <p class="text-8xl font-black text-brand-green mb-6">#{info[:code]}</p>
            <h1 class="text-2xl font-bold text-brand-blue mb-3">#{info[:title]}</h1>
            <p class="text-brand-grey mb-8">#{info[:message]}</p>
            <%= link_to "Retour à l'accueil", root_path, class: "btn-primary" %>
          </div>
        </div>
      ERB
    end
  end

  # ---------------------------------------------------------------------------
  # VUES DEVISE (Tailwind)
  # ---------------------------------------------------------------------------

  if use_devise
  generate "devise:views"

  # Connexion (sessions/new)
  remove_file "app/views/devise/sessions/new.html.erb"
  create_file "app/views/devise/sessions/new.html.erb" do
    btn_class = use_daisyui ? "btn btn-primary w-full" : "btn-primary w-full"
    input_class = use_daisyui ? "input input-bordered w-full" : "form-input"
    label_class = use_daisyui ? "label-text font-medium" : "form-label"

    <<~ERB
      <%= content_for :meta_title, "Se connecter" %>
      <%= content_for :no_navbar, true %>
      <%= content_for :no_footer, true %>

      <div class="min-h-screen flex">
        <!-- Formulaire -->
        <div class="flex-1 flex items-center justify-center p-8">
          <div class="w-full max-w-md">
            <div class="mb-10">
              <%= link_to root_path do %>
                <%= image_tag "logo.svg", class: "h-12 w-auto", alt: "Logo" %>
              <% end %>
            </div>

            <h1 class="text-3xl font-bold text-brand-blue mb-2">Heureux de vous revoir !</h1>
            <p class="text-brand-grey mb-8">Connectez-vous à votre compte</p>

            <%= simple_form_for(resource, as: resource_name, url: session_path(resource_name),
                html: { data: { turbo: false } }) do |f| %>
              <%= f.error_notification class: "text-sm text-red-600 mb-4 block" %>

              <div class="space-y-4 mb-6">
                <%= f.input :email,
                    label: "Email",
                    placeholder: "votre@email.com",
                    input_html: { class: "#{input_class}", autocomplete: "email" },
                    label_html: { class: "#{label_class}" } %>
                <%= f.input :password,
                    label: "Mot de passe",
                    placeholder: "••••••••",
                    input_html: { class: "#{input_class}", autocomplete: "current-password" },
                    label_html: { class: "#{label_class}" } %>
              </div>

              <div class="flex justify-end mb-6">
                <%= link_to "Mot de passe oublié ?", new_user_password_path,
                    class: "text-sm text-brand-grey hover:text-brand-blue transition-colors" %>
              </div>

              <%= f.button :submit, "Se connecter", class: "#{btn_class}" %>
            <% end %>

            <p class="text-center mt-6 text-sm text-brand-grey">
              Pas encore de compte ?
              <%= link_to "Créer un compte", new_user_registration_path,
                  class: "text-brand-green font-semibold hover:underline" %>
            </p>
          </div>
        </div>

        <!-- Visuel (masqué sur mobile) -->
        <div class="hidden lg:block lg:w-1/2 bg-slate-100 overflow-hidden">
          <%= image_tag "banner.svg", class: "w-full h-full object-cover", alt: "" %>
        </div>
      </div>
    ERB
  end

  # Inscription (registrations/new)
  remove_file "app/views/devise/registrations/new.html.erb"
  create_file "app/views/devise/registrations/new.html.erb" do
    btn_class = use_daisyui ? "btn btn-primary w-full" : "btn-primary w-full"
    input_class = use_daisyui ? "input input-bordered w-full" : "form-input"
    label_class = use_daisyui ? "label-text font-medium" : "form-label"

    <<~ERB
      <%= content_for :meta_title, "Créer un compte" %>
      <%= content_for :no_navbar, true %>
      <%= content_for :no_footer, true %>

      <div class="min-h-screen flex items-center justify-center p-8">
        <div class="w-full max-w-md">
          <div class="mb-10">
            <%= link_to root_path do %>
              <%= image_tag "logo.svg", class: "h-12 w-auto", alt: "Logo" %>
            <% end %>
          </div>

          <h1 class="text-3xl font-bold text-brand-blue mb-8">Créer votre compte</h1>

          <%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name),
              html: { data: { turbo: false } }) do |f| %>
            <%= f.error_notification class: "text-sm text-red-600 mb-4 block" %>

            <div class="space-y-4 mb-6">
              <%= f.input :email,
                  label: "Email",
                  placeholder: "votre@email.com",
                  input_html: { class: "#{input_class}", autocomplete: "email" },
                  label_html: { class: "#{label_class}" } %>
              <%= f.input :password,
                  label: "Mot de passe",
                  placeholder: "••••••••",
                  hint: "8 caractères minimum",
                  input_html: { class: "#{input_class}", autocomplete: "new-password" },
                  label_html: { class: "#{label_class}" } %>
              <%= f.input :password_confirmation,
                  label: "Confirmer le mot de passe",
                  placeholder: "••••••••",
                  input_html: { class: "#{input_class}", autocomplete: "new-password" },
                  label_html: { class: "#{label_class}" } %>
            </div>

            <%= f.button :submit, "C'est parti !", class: "#{btn_class}" %>
          <% end %>

          <div class="relative my-6">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-slate-200"></div>
            </div>
            <div class="relative flex justify-center">
              <span class="px-4 bg-white text-sm text-brand-grey">OU</span>
            </div>
          </div>

          <p class="text-center text-sm text-brand-grey">
            Déjà un compte ?
            <%= link_to "Se connecter", new_user_session_path,
                class: "text-brand-green font-semibold hover:underline" %>
          </p>
        </div>
      </div>
    ERB
  end

  # Modifier mon compte (registrations/edit)
  remove_file "app/views/devise/registrations/edit.html.erb"
  create_file "app/views/devise/registrations/edit.html.erb" do
    btn_class = use_daisyui ? "btn btn-primary w-full" : "btn-primary w-full"
    btn_danger_class = use_daisyui ? "btn btn-error btn-sm" : "btn-danger text-sm py-2 px-4"
    input_class = use_daisyui ? "input input-bordered w-full" : "form-input"
    label_class = use_daisyui ? "label-text font-medium" : "form-label"

    <<~ERB
      <%= content_for :meta_title, "Mon compte" %>

      <div class="max-w-lg mx-auto px-4 py-12">
        <h1 class="text-2xl font-bold text-brand-blue mb-8">Modifier mon compte</h1>

        <%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name),
            html: { method: :put, data: { turbo: false } }) do |f| %>
          <%= f.error_notification class: "text-sm text-red-600 mb-4 block" %>

          <div class="card mb-6 space-y-4">
            <h2 class="text-base font-semibold text-brand-blue">Informations</h2>
            <%= f.input :email,
                label: "Email",
                required: false,
                input_html: { class: "#{input_class}", autocomplete: "email" },
                label_html: { class: "#{label_class}" } %>
          </div>

          <div class="card mb-6 space-y-4">
            <h2 class="text-base font-semibold text-brand-blue">Changer de mot de passe</h2>
            <%= f.input :password,
                label: "Nouveau mot de passe",
                placeholder: "••••••••",
                hint: "Laisser vide pour ne pas le modifier",
                required: false,
                input_html: { class: "#{input_class}", autocomplete: "new-password" },
                label_html: { class: "#{label_class}" } %>
            <%= f.input :password_confirmation,
                label: "Confirmer le nouveau mot de passe",
                placeholder: "••••••••",
                required: false,
                input_html: { class: "#{input_class}", autocomplete: "new-password" },
                label_html: { class: "#{label_class}" } %>
          </div>

          <div class="card mb-6">
            <h2 class="text-base font-semibold text-brand-blue mb-4">Confirmation</h2>
            <%= f.input :current_password,
                label: "Mot de passe actuel",
                placeholder: "••••••••",
                hint: "Requis pour valider les modifications",
                required: true,
                input_html: { class: "#{input_class}", autocomplete: "current-password" },
                label_html: { class: "#{label_class}" } %>
          </div>

          <%= f.button :submit, "Sauvegarder", class: "#{btn_class}" %>
        <% end %>

        <div class="mt-10 pt-6 border-t border-slate-200">
          <h2 class="text-base font-semibold text-brand-blue mb-2">Zone dangereuse</h2>
          <p class="text-sm text-brand-grey mb-4">La suppression de votre compte est irréversible.</p>
          <%= button_to "Supprimer mon compte", registration_path(resource_name),
              method: :delete,
              data: { turbo_confirm: "Êtes-vous sûr ? Cette action est irréversible." },
              class: "#{btn_danger_class}" %>
        </div>
      </div>
    ERB
  end

  # Mot de passe oublié (passwords/new)
  remove_file "app/views/devise/passwords/new.html.erb"
  create_file "app/views/devise/passwords/new.html.erb" do
    btn_class = use_daisyui ? "btn btn-primary w-full" : "btn-primary w-full"
    input_class = use_daisyui ? "input input-bordered w-full" : "form-input"
    label_class = use_daisyui ? "label-text font-medium" : "form-label"

    <<~ERB
      <%= content_for :meta_title, "Mot de passe oublié" %>
      <%= content_for :no_navbar, true %>
      <%= content_for :no_footer, true %>

      <div class="min-h-screen flex items-center justify-center p-8">
        <div class="w-full max-w-md">
          <div class="mb-10">
            <%= link_to root_path do %>
              <%= image_tag "logo.svg", class: "h-12 w-auto", alt: "Logo" %>
            <% end %>
          </div>

          <h1 class="text-3xl font-bold text-brand-blue mb-2">Mot de passe oublié ?</h1>
          <p class="text-brand-grey mb-8">
            Entrez votre email pour recevoir les instructions de réinitialisation.
          </p>

          <%= simple_form_for(resource, as: resource_name, url: password_path(resource_name),
              html: { method: :post, data: { turbo: false } }) do |f| %>
            <%= f.error_notification class: "text-sm text-red-600 mb-4 block" %>

            <div class="mb-6">
              <%= f.input :email,
                  label: "Email",
                  placeholder: "votre@email.com",
                  input_html: { class: "#{input_class}", autocomplete: "email" },
                  label_html: { class: "#{label_class}" } %>
            </div>

            <%= f.button :submit, "Envoyer les instructions", class: "#{btn_class}" %>
          <% end %>

          <p class="text-center mt-6 text-sm text-brand-grey">
            <%= link_to "← Retour à la connexion", new_user_session_path,
                class: "text-brand-green font-medium hover:underline" %>
          </p>
        </div>
      </div>
    ERB
  end

  # Réinitialisation mot de passe (passwords/edit)
  remove_file "app/views/devise/passwords/edit.html.erb"
  create_file "app/views/devise/passwords/edit.html.erb" do
    btn_class = use_daisyui ? "btn btn-primary w-full" : "btn-primary w-full"
    input_class = use_daisyui ? "input input-bordered w-full" : "form-input"
    label_class = use_daisyui ? "label-text font-medium" : "form-label"

    <<~ERB
      <%= content_for :meta_title, "Nouveau mot de passe" %>
      <%= content_for :no_navbar, true %>
      <%= content_for :no_footer, true %>

      <div class="min-h-screen flex items-center justify-center p-8">
        <div class="w-full max-w-md">
          <div class="mb-10">
            <%= link_to root_path do %>
              <%= image_tag "logo.svg", class: "h-12 w-auto", alt: "Logo" %>
            <% end %>
          </div>

          <h1 class="text-3xl font-bold text-brand-blue mb-2">Nouveau mot de passe</h1>
          <p class="text-brand-grey mb-8">Choisissez un mot de passe sécurisé.</p>

          <%= simple_form_for(resource, as: resource_name, url: password_path(resource_name),
              html: { method: :put, data: { turbo: false } }) do |f| %>
            <%= f.error_notification class: "text-sm text-red-600 mb-4 block" %>
            <%= f.hidden_field :reset_password_token %>

            <div class="space-y-4 mb-6">
              <%= f.input :password,
                  label: "Nouveau mot de passe",
                  placeholder: "••••••••",
                  hint: "8 caractères minimum",
                  input_html: { class: "#{input_class}", autocomplete: "new-password" },
                  label_html: { class: "#{label_class}" } %>
              <%= f.input :password_confirmation,
                  label: "Confirmer le mot de passe",
                  placeholder: "••••••••",
                  input_html: { class: "#{input_class}", autocomplete: "new-password" },
                  label_html: { class: "#{label_class}" } %>
            </div>

            <%= f.button :submit, "Enregistrer le mot de passe", class: "#{btn_class}" %>
          <% end %>
        </div>
      </div>
    ERB
  end
  end # use_devise

  # ---------------------------------------------------------------------------
  # ROUTES
  # ---------------------------------------------------------------------------

  # Nettoyer la route get "/" si elle existe
  gsub_file "config/routes.rb", /^\s*# root ["']posts#index["']\n/, ""

  inject_into_file "config/routes.rb", after: "Rails.application.routes.draw do\n" do
    <<~RUBY
        root to: "pages#home"

        # Pages d'erreur personnalisées
        get "/404", to: "errors#not_found"
        get "/422", to: "errors#unprocessable"
        get "/500", to: "errors#internal_server_error"

    RUBY
  end

  # ---------------------------------------------------------------------------
  # LOCALES
  # ---------------------------------------------------------------------------

  create_file "config/locales/fr.yml" do
    <<~YAML
      fr:
        errors:
          unauthorized: "Vous n'êtes pas autorisé à réaliser cette action."
        devise:
          sessions:
            captcha_failed: "Connexion refusée — vous avez été identifié comme un bot."
          failure:
            locked: "Votre compte a été verrouillé suite à de trop nombreuses tentatives."
    YAML
  end

  # ---------------------------------------------------------------------------
  # ENVIRONNEMENTS
  # ---------------------------------------------------------------------------

  # Development — Letter Opener
  environment(nil, env: :development) do
    <<~RUBY
      config.action_mailer.delivery_method = :letter_opener
      config.action_mailer.perform_deliveries = true
      config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
    RUBY
  end

  # Production — Postmark
  if use_postmark
    environment(nil, env: :production) do
      <<~RUBY
        config.action_mailer.delivery_method = :postmark
        config.action_mailer.postmark_settings = { api_token: ENV["POSTMARK_API_TOKEN"] }
        config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "example.com"), protocol: "https" }
      RUBY
    end
  end

  # ---------------------------------------------------------------------------
  # SEEDS
  # ---------------------------------------------------------------------------

  remove_file "db/seeds.rb"
  create_file "db/seeds.rb" do
    if use_devise
      <<~RUBY
        # frozen_string_literal: true
        return unless Rails.env.development?

        admin = User.find_or_create_by!(email: "dev@example.com") do |u|
          u.password              = "devpassword123!"
          u.password_confirmation = "devpassword123!"
          u.admin                 = true
        end

        puts "✅ Seed : admin créé (\#{admin.email})"
      RUBY
    else
      <<~RUBY
        # frozen_string_literal: true
        # Ajoute ici tes données de seed
        puts "✅ Seeds chargées."
      RUBY
    end
  end

  # ---------------------------------------------------------------------------
  # .ENV EXEMPLE
  # ---------------------------------------------------------------------------

  create_file ".env.example" do
    postmark_vars = use_postmark ? "\nPOSTMARK_API_TOKEN=\n" : ""

    <<~ENV
      # Application
      APP_NAME=#{app_name.split("_").map(&:capitalize).join(" ")}
      APP_HOST=example.com
      APP_DESCRIPTION=

      # Base de données (configuré dans database.yml)
      DATABASE_URL=

      # Mailer
      MAILER_SENDER=noreply@example.com
      #{postmark_vars}
      # CAPTCHA (optionnel)
      # RECAPTCHA_SITE_KEY=
      # RECAPTCHA_SECRET_KEY=
    ENV
  end

  append_to_file ".gitignore", "\n# Variables d'environnement\n.env\n.env.local\n"

  # ---------------------------------------------------------------------------
  # DATABASE & GIT
  # ---------------------------------------------------------------------------

  # Compilation CSS initiale — génère app/assets/builds/tailwind.css
  # Sans ça, stylesheet_link_tag "tailwind" lève une erreur au premier démarrage
  rails_command "tailwindcss:build"

  rails_command "db:create"
  rails_command "db:migrate"
  rails_command "db:seed"

  git :init
  git add: "."
  git commit: %Q(-m "Initial commit — Rails 8.1 + Tailwind#{use_daisyui ? " + DaisyUI" : ""}")

  # ---------------------------------------------------------------------------
  # RÉSUMÉ
  # ---------------------------------------------------------------------------

  puts "\n#{"=" * 60}"
  puts "  ✅ Application prête !"
  puts ""
  puts "  Lancer le serveur :"
  puts "    bin/dev"
  puts ""
  puts "  Compte dev : dev@example.com / devpassword123!"
  puts "=" * 60
end
