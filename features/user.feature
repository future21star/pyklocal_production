Feature: User

  In order to buy a product 
  I want to test that all activity is working

  Scenario: I want to buy a product
    Given I am a user with email "test@w3villa.com" with password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234" 
    And I should goto the shop page 
    And I should select a product name "Iphone" 
    Then I should goto the checkout process for product "I-Phone" with quantity "4"
    And I should fill the billing address 
    And I should make payment by check and proceed
    Then I should see "Thank you for your business. Please print out a copy of this confirmation page for your records"