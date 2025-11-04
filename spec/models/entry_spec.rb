require 'rails_helper'

RSpec.describe Entry, type: :model do
  it "has a valid factory" do
    expect(create :entry).to be_valid
  end
end
