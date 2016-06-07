Feature: Seller 

  In order to create store 
  I want to test that all activity is working

  Scenario: I want to create a store for a product and checking a stock management 
    Given I am a user with email "test@w3villa.com" with password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234"
    And I want to Apply for new store name "shopper&stop"
    And I fill the all the details for new store registration
    And I should add a new product "I-Phone" with price "1000"
    And I should Update option type value in product
    And I should update variant with cost price "1000" 
    And I should check product is added in product shop page 
    And I want to update product "I-Phone" details with Image
    And I want to also update stock managment with quantity "10"
    
 Scenario: I want to buy a product 
    Given I am a user with email "test@w3villa.com" with password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234" 
    And I should goto the shop page 
    And I should select a product name "Iphone" 
    Then I should goto the checkout process for product "I-Phone" with quantity "4"
    And I should fill the billing address 
    And I should make payment by check and proceed
    Then I should see "Thank you for your business. Please print out a copy of this confirmation page for your records" 



   