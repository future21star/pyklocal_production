STORE_PAYMENT_MODE = {btc: 'Bitcoin', paypal: 'Paypal', bank_wire: 'Bank Wire', other: "Other"}
DELIVERY_TYPE = {home_delivery: 'Home Delivery', take_away: 'Take Away'}
REDIS_CLIENT = Redis.new(YAML.load_file(Rails.root.to_s + '/config/redis.yml')[Rails.env])