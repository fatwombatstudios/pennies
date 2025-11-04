require 'rails_helper'

RSpec.describe Tx, type: :model do
  it "has a valid factory" do
    expect(create :tx).to be_valid
  end
end
