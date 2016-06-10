# seller.feature

When(/^I am user with email "([^"]*)" and password "([^"]*)"$/) do |arg1, arg2|
  role = Spree::Role.where(name:"merchant").first
  Spree::User.create(email:"test@w3villa.com",password:"temp1234",password_confirmation:"temp1234",spree_role_ids:[role.id])  
end

  # Scenario : 1

When(/^I want to Apply for new store$/) do
  click_on"Sell with us"
  click_on"Apply For New Store"
end


When(/^I fill the all the details for new store registration$/) do
  attach_file('merchant_store_logo', File.join(Rails.root, '/features/support/shop1.png'))
  steps %Q{
    And I fill in "merchant_store_name" with "Shopper & Stop" 
    And I fill in "merchant_store_manager_first_name" with "Gopal"
    And I fill in "merchant_store_manager_last_name" with "last" 
    And I fill in "merchant_store_phone_number" with "9879879879"
    And I fill in "merchant_store_site_url" with "www.shopperstop.com"
    And I fill in "merchant_store_street_number" with "captown city"
    And I fill in "merchant_store_city" with "noida-76"
    And I fill in "merchant_store_zipcode" with "201301"
    And I fill in "merchant_store_state" with "Utter pradesh"
    And I fill in "merchant_store_country" with "india"
  }
  find_field('Bag').click
  find_field('Clothing').click
  click_on"Create" 
  click_on"Close"
  sleep 3

end

  #Scenario :2

When(/^I want to sign in as "([^"]*)" with password "([^"]*)"$/) do |email, password|
  steps %Q{
    When I go to the home page
    When I follow "Login"
    And I fill in "spree_user_email" with "#{email}"  
    And I fill in "spree_user_password" with "#{password}"
    And I press "Login"
  }
end

When(/^I want to Apply for new store name "([^"]*)"$/) do |arg1|
  steps %Q{
    And I want to Apply for new store 
    And I fill the all the details for new store registration
  }
end

When(/^I should add a new product "([^"]*)" with price "([^"]*)"$/) do |product, price|
  click_on"Add Product"
  fill_in('product_name',:with => product)
  fill_in('product_price',:with => price)
  page.execute_script(%{$("#product_available_on").val('2016/04/04')});
  select("Default", :from =>"product_shipping_category_id" )
  click_on"Save"
  page.execute_script(%{$("#products div:contains('fila shoes') .buy-now a:contains('Edit')")});
end


  # Scenario : 3
When(/^I should add a new product "([^"]*)"$/) do |arg1|
  steps %Q{
    And I should add a new product "I-Phone" with price "1000"
  }
end

When(/^I should Update option type value in product$/) do
  find("#s2id_product_option_type_ids").click
  sleep 1
  find('.select2-results',:text=>"Size (size)").click
  click_on"Update Product"
end

When(/^I should update variant with cost price "([^"]*)"$/) do |cost_price|
  click_on"VARIANTS"
  sleep 1
  click_on"Create One"
  fill_in("variant_cost_price",:with=>cost_price)
  click_on"Create"
end

When(/^I should check product is added in product shop page$/) do
  click_on"Go to store"
  page.evaluate_script(%{$("#products .product-item ").length}).should == 1;
#   # click_on"All Categories"
#   # page.evaluate_script(%{$(".product-layout .product-grid ").length}).should == 1
end

When(/^I want to update product "([^"]*)" details with Image$/) do |image|
  click_on"Edit"  
  click_on"IMAGES"
  sleep 1
  click_on"Add new image"
  attach_file('image_attachment', File.join(Rails.root, '/features/support/iphone.jpg'))
  click_on"Create"
  click_on"All Categories"
  
end

When(/^I want to also update stock managment with quantity "([^"]*)"$/) do |arg1|
  click_on"Go to store"
  click_on"Edit"
  click_on"STOCK MANAGEMENT"
  sleep 1
  # fill_in('stock_movement_quantity',:with => stock)
  # sleep 1
  click_on"Add Stock"
  # page.find(".odd").should have_content stock == true
end

When(/^I should add the product in to add to cart$/) do
  click_on"Add To Cart"
  click_on"Checkout"
end


Then(/^I should go store dashboard$/) do
  click_on"Go to Store"
end

Then(/^I should check the delivery status$/) do
  click_on"View Order"
  click_on"Ready to pickup"
  steps %Q{
    Then I should see "Cancel"
  }
end












# user.features-----------
#  Scenario : 1
When(/^I should go user "([^"]*)" account$/) do |user|
    click_on user
end

When(/^I should update user details with first_name "([^"]*)" and last_name "([^"]*)"$/) do |first_name, last_name|
  steps %Q{
    And I fill in "InputFirstName" with "#{first_name}"
    And I fill in "InputLastName" with "#{last_name}"
  }
  click_on"Update Information"
end

When(/^I want to add my payment preferance$/) do
  debugger
end


#  Scenario : 2
When(/^I should goto the shop page$/) do
  click_on"All Categories"
end

When(/^I should select a product name "([^"]*)"$/) do |product|
  sleep 5
  click_on product
end

Then(/^I should goto the checkout process for product "([^"]*)" with quantity "([^"]*)"$/) do |product, quantity|
  fill_in("input-quantity", :with=> quantity)
  click_on"Add To Cart"
  click_on"Checkout"
end

Then(/^I should fill the billing address$/) do
   steps %Q{
    And I fill in "order_bill_address_attributes_firstname" with "Gopal" 
    And I fill in "order_bill_address_attributes_lastname" with "sharma" 
    And I fill in "order_bill_address_attributes_address1" with "13004" 
    And I fill in "order_bill_address_attributes_address2" with "captown"
    And I fill in "order_bill_address_attributes_city" with "New York" 
    When I select "Gaum" from "order_bill_address_attributes_state_id"
    And I fill in "order_bill_address_attributes_zipcode" with "49101" 
    And I fill in "order_bill_address_attributes_phone" with "9685741425" 
    And I press "Save and Continue"
  }
end

Then(/^I should make payment by check and proceed$/) do
  click_on "Save and Continue"
  click_on "Save and Continue"
end

Then(/^I should check order deatils in user account$/) do
  click_on"View your order history"
  steps %Q{
    Then I should see "Order Status pending"
  }
end


Then(/^I should break$/) do
  debugger
end



