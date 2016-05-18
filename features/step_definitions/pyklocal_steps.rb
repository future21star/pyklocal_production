
# # sellet.feature  

When(/^I am a user$/) do
  Spree::User.create(email: "test@w3villa.com", password: "temp1234", password_confirmation: "temp1234",spree_role_ids:Spree::Role.first.id)
end


Then(/^I should break$/) do
  debugger
end