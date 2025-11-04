require 'rails_helper'

RSpec.describe "/accounts", type: :request do
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:account) { create :account }

  describe "GET /index" do
    it "renders a successful response" do
      get accounts_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get account_url(account)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_account_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_account_url(account)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Account" do
        expect {
          post accounts_url, params: { account: valid_attributes }
        }.to change(Account, :count).by(1)
      end

      it "redirects to the created account" do
        post accounts_url, params: { account: valid_attributes }
        expect(response).to redirect_to(account_url(Account.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Account" do
        expect {
          post accounts_url, params: { account: invalid_attributes }
        }.to change(Account, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post accounts_url, params: { account: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested account" do
        account = Account.create! valid_attributes
        patch account_url(account), params: { account: new_attributes }
        account.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the account" do
        account = Account.create! valid_attributes
        patch account_url(account), params: { account: new_attributes }
        account.reload
        expect(response).to redirect_to(account_url(account))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        account = Account.create! valid_attributes
        patch account_url(account), params: { account: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested account and redirects to the accounts list" do
      account = create :account
      expect(Account.count).to eq 1

      delete account_url(account)

      expect(Account.count).to eq 0
      expect(response).to redirect_to(accounts_url)
    end
  end
end
