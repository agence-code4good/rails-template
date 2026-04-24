# frozen_string_literal: true

# config/environments/staging.rb
# Copier ce fichier dans config/environments/ de votre application Rails.
# Staging = proche production, avec quelques exceptions (ex : emails interceptés).

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  # Erreurs en production (pas de page de debug)
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Assets Propshaft
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assets.compile = false

  # Logging
  config.log_level = :info
  config.log_tags = [:request_id]

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Mailer — Postmark ou SMTP
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :postmark
  config.action_mailer.postmark_settings = { api_token: ENV["POSTMARK_API_TOKEN"] }
  config.action_mailer.default_url_options = {
    host:     ENV.fetch("APP_HOST", "staging.example.com"),
    protocol: "https"
  }

  # SSL obligatoire
  config.force_ssl = true

  # Active Storage
  config.active_storage.service = :local

  # Internationalisation
  config.i18n.fallbacks = true

  # Dépréciation : loggée, pas levée
  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false
end
