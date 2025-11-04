require 'rails_helper'

RSpec.describe "entries/edit", type: :view do
  let(:entry) {
    Entry.create!(
      currency: "MyString",
      amount: "9.99",
      debit_account: nil,
      credit_account: nil
    )
  }

  before(:each) do
    assign(:entry, entry)
  end

  it "renders the edit entry form" do
    render

    assert_select "form[action=?][method=?]", entry_path(entry), "post" do

      assert_select "input[name=?]", "entry[currency]"

      assert_select "input[name=?]", "entry[amount]"

      assert_select "input[name=?]", "entry[debit_account_id]"

      assert_select "input[name=?]", "entry[credit_account_id]"
    end
  end
end
