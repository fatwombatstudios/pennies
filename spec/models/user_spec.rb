require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(create :user).to be_valid
  end

  it "requires a name" do
    user = build :user, name: nil
    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it "requires an email" do
    user = build :user, email: nil
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "requires a unique email" do
    create :user, email: "test@example.com"
    user = build :user, email: "test@example.com"
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "requires a valid email format" do
    user = build :user, email: "invalid_email"
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is invalid")
  end

  it "requires a password with minimum length" do
    user = build :user, password: "short"
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
  end

  it "authenticates with correct password" do
    user = create :user, password: "password123"
    expect(user.authenticate("password123")).to eq(user)
  end

  it "does not authenticate with incorrect password" do
    user = create :user, password: "password123"
    expect(user.authenticate("wrong_password")).to be_falsey
  end
end
