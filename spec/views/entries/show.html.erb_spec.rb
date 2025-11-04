require 'rails_helper'

RSpec.describe "entries/show", type: :view do
  before(:each) do
    assign(:entry, Entry.create!(
      currency: "Currency",
      amount: "9.99",
      debit_account: nil,
      credit_account: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Currency/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
