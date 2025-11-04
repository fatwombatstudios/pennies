require "rails_helper"

RSpec.describe Transaction do
  it "has a valid factory" do
    expect(create :transaction).to be_valid
  end
end
