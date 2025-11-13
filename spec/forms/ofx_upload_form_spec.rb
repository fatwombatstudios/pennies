require "rails_helper"

RSpec.describe OfxUploadForm, type: :model do
  let(:account) { create(:account) }
  let(:real_account) { create(:bucket, account: account, account_type: :real, name: "Checking") }
  let(:virtual_account) { create(:bucket, account: account, account_type: :spending, name: "Groceries") }
  let(:mock_file) { double("file") }

  describe "validations" do
    describe "ofx_file" do
      it "is invalid without an ofx_file" do
        form = OfxUploadForm.new(
          ofx_file: nil,
          real_account_id: real_account.id,
          account: account
        )

        expect(form).not_to be_valid
        expect(form.errors[:ofx_file]).to include("Please select an OFX file to upload")
      end

      it "is valid with an ofx_file" do
        form = OfxUploadForm.new(
          ofx_file: mock_file,
          real_account_id: real_account.id,
          account: account
        )

        expect(form).to be_valid
      end
    end

    describe "real_account_id" do
      it "is invalid without a real_account_id" do
        form = OfxUploadForm.new(
          ofx_file: mock_file,
          real_account_id: nil,
          account: account
        )

        expect(form).not_to be_valid
        expect(form.errors[:real_account_id]).to include("Please select a real account")
      end

      it "is invalid with a non-existent real_account_id" do
        form = OfxUploadForm.new(
          ofx_file: mock_file,
          real_account_id: 99999,
          account: account
        )

        expect(form).not_to be_valid
        expect(form.errors[:real_account_id]).to include("Invalid real account selected")
      end

      it "is invalid when real_account_id belongs to a virtual account" do
        form = OfxUploadForm.new(
          ofx_file: mock_file,
          real_account_id: virtual_account.id,
          account: account
        )

        expect(form).not_to be_valid
        expect(form.errors[:real_account_id]).to include("Invalid real account selected")
      end

      it "is valid with a valid real_account_id" do
        form = OfxUploadForm.new(
          ofx_file: mock_file,
          real_account_id: real_account.id,
          account: account
        )

        expect(form).to be_valid
      end
    end
  end

  describe "#real_account" do
    it "returns the real account when valid" do
      form = OfxUploadForm.new(
        ofx_file: mock_file,
        real_account_id: real_account.id,
        account: account
      )

      expect(form.real_account).to eq(real_account)
    end

    it "returns nil when real_account_id is nil" do
      form = OfxUploadForm.new(
        ofx_file: mock_file,
        real_account_id: nil,
        account: account
      )

      expect(form.real_account).to be_nil
    end

    it "returns nil when account is not set" do
      form = OfxUploadForm.new(
        ofx_file: mock_file,
        real_account_id: real_account.id
      )

      expect(form.real_account).to be_nil
    end

    it "returns nil when real_account_id does not exist" do
      form = OfxUploadForm.new(
        ofx_file: mock_file,
        real_account_id: 99999,
        account: account
      )

      expect(form.real_account).to be_nil
    end

    it "memoizes the result" do
      form = OfxUploadForm.new(
        ofx_file: mock_file,
        real_account_id: real_account.id,
        account: account
      )

      # Call twice to test memoization
      first_call = form.real_account
      second_call = form.real_account

      expect(first_call).to eq(second_call)
      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end
end
