require "rails_helper"

RSpec.describe "Buckets", type: :feature do
  let(:user) { create :user }

  before :each do
    sign_in_as user
  end

  scenario "browsing all buckets" do
    create :bucket, name: "Savings"

    visit "/buckets"

    expect(page).to have_content "Buckets"
    expect(page).to have_content "Savings"
  end

  scenario "a user views a bucket" do
    bucket = create :bucket, name: "Savings"

    visit "/buckets/#{bucket.id}"

    expect(page).to have_content "Savings Bucket"
  end

  scenario "a user creates a new virtual bucket" do
    visit "/buckets/new"

    fill_in "Name", with: "Groceries"
    fill_in "Description", with: "For food and drink"

    click_button "Create Bucket"

    expect(page).to have_content "Buckets"
    expect(page).to have_content "Groceries"
    expect(page).to have_content "For food and drink"
    expect(page).to have_content "Spending"
  end
end
