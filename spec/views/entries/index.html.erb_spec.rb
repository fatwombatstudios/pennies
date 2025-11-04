require 'rails_helper'

RSpec.describe "entries/index", type: :view do
  before(:each) do
    assign(:entries, [
      Entry.create!(
        currency: "Currency",
        amount: "9.99",
        debit_account: nil,
        credit_account: nil
      ),
      Entry.create!(
        currency: "Currency",
        amount: "9.99",
        debit_account: nil,
        credit_account: nil
      )
    ])
  end

  it "renders a list of entries" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Currency".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
