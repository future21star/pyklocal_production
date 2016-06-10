API_CONFIG = YAML.load_file("#{Rails.root}/config/api_config.yml")[Rails.env]
ASIN::Configuration.configure do |config|
  config.secret        = API_CONFIG['amazon_access_secret']
  config.key           = API_CONFIG['amazon_access_key']
  config.associate_tag = "pricesinrupee-21"
  config.host          = "webservices.amazon.in"
end

AMAZON_CLIENT = ASIN::Client.instance
