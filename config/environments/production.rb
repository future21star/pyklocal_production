Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  Sunspot.config.solr.url = 'http://localhost:8983/solr'

  Rails.application.config.middleware.use ExceptionNotification::Rack, email: {
    :email_prefix => "[Error 500] ",
    :sender_address => %{"PykLocal Exception" <exception@pyklocal.com>},
    :exception_recipients => %w{ishank@w3villa.com  manish.rai@w3villa.com}
  }

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  config.action_mailer.asset_host = "http://34.203.36.151"
  config.action_mailer.default_url_options = { :host => 'http://34.203.36.151' }
  config.action_mailer.delivery_method = :smtp
  # ActionMailer::Base.smtp_settings = {
  #   # :enable_starttls_auto => false,
  #   # :openssl_verify_mode => 'none'
  #   # :address => "smpt.mandrillapp.com",
  #   # :port => 587,
  #   # :enable_starttls_auto => true,
  #   # :user_name => "pyklocal",
  #   # :password => "E7BhM0LgZKaanbD1DfaW2w",
  #   # :authentication => "login"

  #   :address => "email-smtp.us-west-2.amazonaws.com",
  #   :port => 587,
  #   :user_name => ENV["AKIAIIF5FWQHO2TR2VUA"],
  #   :password => ENV["Ag4X4Xuuhm/uXkN2dag5sequCBIWnre9hRGhBhhS2bsb"],
  #   :authentication => :login,
  #   :enable_starttls_auto => true
  # }
  config.action_mailer.smtp_settings = {
    :address => "email-smtp.us-west-2.amazonaws.com",
    :port => "25",
    :user_name => "AKIAJLEUITA3BKXV2YAQ",
    :password => "Ai87FmC2QKV2g2I00UKmF2Oz1wGaAdYBwyQ2qWwdWg+e",
    :authentication => :login,
    :enable_starttls_auto => true
  }

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
