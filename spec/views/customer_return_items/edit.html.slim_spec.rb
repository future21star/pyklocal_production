require 'rails_helper'

RSpec.describe "customer_return_items/edit", type: :view do
  before(:each) do
    @customer_return_item = assign(:customer_return_item, CustomerReturnItem.create!())
  end

  it "renders the edit customer_return_item form" do
    render

    assert_select "form[action=?][method=?]", customer_return_item_path(@customer_return_item), "post" do
    end
  end
end
