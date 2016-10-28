module Spree
  AuthConfiguration.class_eval do
    preference :confirmable, :boolean, :default => true
  end
end
