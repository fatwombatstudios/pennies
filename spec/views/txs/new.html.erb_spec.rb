require 'rails_helper'

RSpec.describe "txs/new", type: :view do
  before(:each) do
    assign(:tx, Tx.new(
      date: Time.current,
      amount: "9.99",
      currency: "MyString",
      description: "MyString"
    ))
  end

  it "renders new tx form" do
    render

    assert_select "form[action=?][method=?]", txs_path, "post" do

      assert_select "input[name=?]", "tx[amount]"

      assert_select "input[name=?]", "tx[currency]"

      assert_select "input[name=?]", "tx[description]"
    end
  end
end
