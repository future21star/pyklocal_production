ASIN_CONFIG = YAML.load_file("#{Rails.root}/config/api_config.yml")[Rails.env]
ASIN::Configuration.configure do |config|
  config.secret        = ASIN_CONFIG['amazon_access_secret']
  config.key           = ASIN_CONFIG['amazon_access_key']
  config.associate_tag = "pkylocal-20"
  config.host          = "webservices.amazon.com"
end

AMAZON_CLIENT = ASIN::Client.instance
