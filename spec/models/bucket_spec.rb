require 'rails_helper'

RSpec.describe Bucket, type: :model do
  it "has a valid factory" do
    expect(create :bucket).to be_valid
  end
end
