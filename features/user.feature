Feature: User profile

	In order to make update user profile 
  I want to check all the activity working


	Scenario: I want to update user profile 
		When I am user with email "test@w3villa.com" and password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234" 
    And I should go user "test@w3villa.com" account 
    And I should update user details with first_name "gopal" and last_name "sharma"


  Scenario: I Want to buy a product
  	When I am user with email "test@w3villa.com" and password "temp1234"
    And I want to sign in as "test@w3villa.com" with password "temp1234" 
    And I should goto the shop page 
    And I should select a product name "Iphone" 
    Then I should goto the checkout process for product "I-Phone" with quantity "4"
    And I should fill the billing address 
    And I should make payment by check and proceed
    Then I should see "Thank you for your business. Please print out a copy of this confirmation page for your records"