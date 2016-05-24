Feature: Seller 

  In order to create store 
  I want to test that all activity is working

  Scenario: I want to create a store for selling a product
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
    
    Then I should break
   