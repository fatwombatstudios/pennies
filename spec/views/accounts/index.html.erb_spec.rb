require 'rails_helper'

RSpec.describe "accounts/index", type: :view do
  before(:each) do
    assign(:accounts, [
      Account.create!(
        name: "Name",
        description: "Description",
        account_type: "Account Type"
      ),
      Account.create!(
        name: "Name",
        description: "Description",
        account_type: "Account Type"
      )
    ])
  end

  it "renders a list of accounts" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Account Type".to_s), count: 2
  end
end
