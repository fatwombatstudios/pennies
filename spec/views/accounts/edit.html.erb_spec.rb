require 'rails_helper'

RSpec.describe "accounts/edit", type: :view do
  let(:account) {
    Account.create!(
      name: "MyString",
      description: "MyString",
      account_type: "MyString"
    )
  }

  before(:each) do
    assign(:account, account)
  end

  it "renders the edit account form" do
    render

    assert_select "form[action=?][method=?]", account_path(account), "post" do

      assert_select "input[name=?]", "account[name]"

      assert_select "input[name=?]", "account[description]"

      assert_select "input[name=?]", "account[account_type]"
    end
  end
end
