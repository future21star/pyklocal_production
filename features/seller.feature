Feature: Seller 

  In order to create store 
  I want to test that all activity is working

  Scenario: I want to create a store for selling a product
    When I am a user
    When I go to the home page  
    When I follow "Login"
    And I fill in "spree_user_email" with "test@w3villa.com"  
    And I fill in "spree_user_password" with "temp1234"
    And I press "Login"
    And I follow "Sell with us"
    And I follow "Apply For New Store"
    Then I should break
   