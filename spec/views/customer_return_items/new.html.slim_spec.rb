require 'rails_helper'

RSpec.describe "customer_return_items/new", type: :view do
  before(:each) do
    assign(:customer_return_item, CustomerReturnItem.new())
  end

  it "renders new customer_return_item form" do
    render

    assert_select "form[action=?][method=?]", customer_return_items_path, "post" do
    end
  end
end
