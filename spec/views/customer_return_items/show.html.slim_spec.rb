require 'rails_helper'

RSpec.describe "customer_return_items/show", type: :view do
  before(:each) do
    @customer_return_item = assign(:customer_return_item, CustomerReturnItem.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
