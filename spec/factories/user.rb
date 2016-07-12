FactoryGirl.define do
  factory :user do
    email "test@rspec.com"
    password "test123"
    password_confirmation "test123"
  end
end
