require 'rails_helper'

RSpec.describe "txs/edit", type: :view do
  let(:tx) {
    Tx.create!(
      date: Time.current,
      amount: "9.99",
      currency: "MyString",
      description: "MyString"
    )
  }

  before(:each) do
    assign(:tx, tx)
  end

  it "renders the edit tx form" do
    render

    assert_select "form[action=?][method=?]", tx_path(tx), "post" do

      assert_select "input[name=?]", "tx[amount]"

      assert_select "input[name=?]", "tx[currency]"

      assert_select "input[name=?]", "tx[description]"
    end
  end
end
