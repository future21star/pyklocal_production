class Feedback < ActiveRecord::Base
  validates :name, :email, :value, :comment, presence: true
end
