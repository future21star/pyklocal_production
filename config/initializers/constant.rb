DELIVERY_TYPE = {home_delivery: 'Home Delivery', pickup: 'Pickup'}
REDIS_CLIENT = Redis.new(YAML.load_file(Rails.root.to_s + '/config/redis.yml')[Rails.env])
DELIVERY_STATE = {packaging: 'Packaging', ready_to_pick: 'Ready To Pick', confirmed_pickup: 'Confirmed Pickup', out_for_delivery: 'Out For Delivery', delivered: 'Delivered', canceled: 'Canceled'}
IMAGE_POSITION = {top: 'Top', middle: 'Middle', bottom: 'Bottom'}