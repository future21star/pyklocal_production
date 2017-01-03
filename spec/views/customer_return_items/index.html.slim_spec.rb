require 'rails_helper'

RSpec.describe "customer_return_items/index", type: :view do
  before(:each) do
    assign(:customer_return_items, [
      CustomerReturnItem.create!(),
      CustomerReturnItem.create!()
    ])
  end

  it "renders a list of customer_return_items" do
    render
  end
end
