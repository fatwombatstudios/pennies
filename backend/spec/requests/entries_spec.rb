require 'rails_helper'

RSpec.describe "/entries", type: :request do
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:user) { create :user }

  describe "public access" do
    it "requires authentication" do
      get entries_url
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "authenticated access" do
    before :each do
      authenticate user
    end

    describe "GET /index" do
      it "renders a successful response" do
        Entry.create! valid_attributes
        get entries_url
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        entry = Entry.create! valid_attributes
        get entry_url(entry)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_entry_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "renders a successful response" do
        entry = Entry.create! valid_attributes
        get edit_entry_url(entry)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new Entry" do
          expect {
            post entries_url, params: { entry: valid_attributes }
          }.to change(Entry, :count).by(1)
        end

        it "redirects to the created entry" do
          post entries_url, params: { entry: valid_attributes }
          expect(response).to redirect_to(entry_url(Entry.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Entry" do
          expect {
            post entries_url, params: { entry: invalid_attributes }
          }.to change(Entry, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post entries_url, params: { entry: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) {
          skip("Add a hash of attributes valid for your model")
        }

        it "updates the requested entry" do
          entry = Entry.create! valid_attributes
          patch entry_url(entry), params: { entry: new_attributes }
          entry.reload
          skip("Add assertions for updated state")
        end

        it "redirects to the entry" do
          entry = Entry.create! valid_attributes
          patch entry_url(entry), params: { entry: new_attributes }
          entry.reload
          expect(response).to redirect_to(entry_url(entry))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          entry = Entry.create! valid_attributes
          patch entry_url(entry), params: { entry: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested entry" do
        entry = Entry.create! valid_attributes
        expect {
          delete entry_url(entry)
        }.to change(Entry, :count).by(-1)
      end

      it "redirects to the entries list" do
        entry = Entry.create! valid_attributes
        delete entry_url(entry)
        expect(response).to redirect_to(entries_url)
      end
    end
  end
end
