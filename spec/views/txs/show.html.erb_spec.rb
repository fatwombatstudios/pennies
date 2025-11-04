require 'rails_helper'

RSpec.describe "txs/show", type: :view do
  before(:each) do
    assign(:tx, Tx.create!(
      date: Time.current,
      amount: "9.99",
      currency: "Currency",
      description: "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Currency/)
    expect(rendered).to match(/Description/)
  end
end
