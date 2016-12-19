Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Custom config below

  # This is the per-application Auth0 key used for signing authentication tokens (shared with Auth0).
  # Please note that this is DIFFERENT from the Auth0 API Management secret used for Auth0 API access.
  # It is needed in order to authenticate initial requests and issue API access tokens subsequently.
  auth_config = YAML.load_file(File.expand_path('../../auth0_dev.yml', __FILE__))
  ENV['AUTH_CLIENT_SECRET'] = auth_config['auth_client_secret']

  # This is the API-private key used for signing API access tokens.
  # The API ID *may* be needed as issuer claim.
  api_secret = YAML.load_file(File.expand_path('../../api_secret_dev.yml', __FILE__))
  ENV['API_SECRET'] = api_secret['api_secret']
  ENV['API_ID']     = api_secret['api_id']
end
