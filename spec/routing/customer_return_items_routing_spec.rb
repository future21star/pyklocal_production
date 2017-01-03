require "rails_helper"

RSpec.describe CustomerReturnItemsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/customer_return_items").to route_to("customer_return_items#index")
    end

    it "routes to #new" do
      expect(:get => "/customer_return_items/new").to route_to("customer_return_items#new")
    end

    it "routes to #show" do
      expect(:get => "/customer_return_items/1").to route_to("customer_return_items#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/customer_return_items/1/edit").to route_to("customer_return_items#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/customer_return_items").to route_to("customer_return_items#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/customer_return_items/1").to route_to("customer_return_items#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/customer_return_items/1").to route_to("customer_return_items#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/customer_return_items/1").to route_to("customer_return_items#destroy", :id => "1")
    end

  end
end
