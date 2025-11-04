require 'rails_helper'

RSpec.describe "txs/index", type: :view do
  before(:each) do
    assign(:txs, [
      Tx.create!(
        date: Time.current,
        amount: "9.99",
        currency: "Currency",
        description: "Description"
      ),
      Tx.create!(
        date: Time.current,
        amount: "9.99",
        currency: "Currency",
        description: "Description"
      )
    ])
  end

  it "renders a list of txs" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Currency".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
  end
end
