Feature: Store Create

  In order to Create Store
  I want to test that the all the activity is working

  Scenario: I want to log in and create store
    When I am user with email "test@w3villa.com" and password "temp1234"
    When I go to the home page  
    When I follow "Login"
    And I fill in "spree_user_email" with "test@w3villa.com"  
    And I fill in "spree_user_password" with "temp1234"
    And I press "Login"
    And I want to Apply for new store 
    And I fill the all the details for new store registration
    Then I should see "shopper&stop"

  Scenario: I want to add a product from mah store shopper&stop
    When I am user with email "test@w3villa.com" and password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234"
    And I want to Apply for new store name "shopper&stop"
    And I should add a new product "I-Phone" with price "1000"

  Scenario: I want to add a product from mah store shopper&stop and all check product list
    When I am user with email "test@w3villa.com" and password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234"
    And I want to Apply for new store name "shopper&stop"
    And I should add a new product "I-Phone" with price "1000"
    And I should go to all product list for mah store  

  Scenario: I want to update product detail and add image
    When I am user with email "test@w3villa.com" and password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234"
    And I want to Apply for new store name "shopper&stop"
    And I should add a new product "I-Phone"
    And I should Update option type value in product
    And I should update variant with cost price "1000" 
    And I should check product is added in product shop page 
    And I want to update product "I-Phone" details with Image
    And I want to also update stock managment with quantity "10"

  Scenario:I Want to check the varaint in store that product is out of stock
    When I am user with email "test@w3villa.com" and password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234"
    And I want to Apply for new store name "shopper&stop"
    And I should add a new product "I-Phone"
    And I should Update option type value in product
    And I should update variant with cost price "1000" 
    And I should check product is added in product shop page 
    And I want to update product "I-Phone" details with Image
    And I should goto the shop page
    And I should select a product name "I-Phone"
    And I Should see "out of store"

  Scenario:I Want to buy a product form store shooper stop
    When I am user with email "test@w3villa.com" and password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234"
    And I want to Apply for new store name "shopper&stop"
    And I should add a new product "I-Phone"
    And I should Update option type value in product
    And I should update variant with cost price "1000" 
    And I should check product is added in product shop page 
    And I want to update product "I-Phone" details with Image
    And I want to also update stock managment with quantity "10"
    And I should goto the shop page
    And I should select a product name "I-Phone"
    And I should add the product in to add to cart
    And I should fill the billing address 
    And I should make payment by check and proceed
    Then I should see "Thank you for your business. Please print out a copy of this confirmation page for your records"
    And I should go store dashboard
    Then I should check the delivery status   



