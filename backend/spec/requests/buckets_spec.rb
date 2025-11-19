require 'rails_helper'

RSpec.describe "/buckets", type: :request do
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:user) { create :user }
  let(:bucket) { create :bucket, account: user.account }

  describe "public access" do
    it "requires authentication" do
      get buckets_url
      expect(response).to redirect_to sign_in_path
    end
  end

  describe "authenticated access" do
    before :each do
      authenticate user
    end

    describe "GET /index" do
      it "renders a successful response" do
        get buckets_url
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        get bucket_url(bucket)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_bucket_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "renders a successful response" do
        get edit_bucket_url(bucket)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new Bucket" do
          expect {
            post buckets_url, params: { bucket: valid_attributes }
          }.to change(Bucket, :count).by(1)
        end

        it "redirects to the created bucket" do
          post buckets_url, params: { bucket: valid_attributes }
          expect(response).to redirect_to(bucket_url(Bucket.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Bucket" do
          expect {
            post buckets_url, params: { bucket: invalid_attributes }
          }.to change(Bucket, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post buckets_url, params: { bucket: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) {
          skip("Add a hash of attributes valid for your model")
        }

        it "updates the requested bucket" do
          bucket = Bucket.create! valid_attributes
          patch bucket_url(bucket), params: { bucket: new_attributes }
          bucket.reload
          skip("Add assertions for updated state")
        end

        it "redirects to the bucket" do
          bucket = Bucket.create! valid_attributes
          patch bucket_url(bucket), params: { bucket: new_attributes }
          bucket.reload
          expect(response).to redirect_to(bucket_url(bucket))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          bucket = Bucket.create! valid_attributes
          patch bucket_url(bucket), params: { bucket: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
