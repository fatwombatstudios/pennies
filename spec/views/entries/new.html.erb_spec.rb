require 'rails_helper'

RSpec.describe "entries/new", type: :view do
  before(:each) do
    assign(:entry, Entry.new(
      currency: "MyString",
      amount: "9.99",
      debit_account: nil,
      credit_account: nil
    ))
  end

  it "renders new entry form" do
    render

    assert_select "form[action=?][method=?]", entries_path, "post" do

      assert_select "input[name=?]", "entry[currency]"

      assert_select "input[name=?]", "entry[amount]"

      assert_select "input[name=?]", "entry[debit_account_id]"

      assert_select "input[name=?]", "entry[credit_account_id]"
    end
  end
end
