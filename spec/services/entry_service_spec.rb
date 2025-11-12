require 'rails_helper'

RSpec.describe EntryService do
  let(:account) { create :account }
  let(:debit_bucket) { create :bucket, account: account }
  let(:credit_bucket) { create :bucket, account: account }
  let(:entry) { create :entry, account: account, debit_account: debit_bucket, credit_account: credit_bucket, amount: 10.0 }
  let(:service) { described_class.new(entry) }

  describe '#initialize' do
    it 'sets the entry' do
      expect(service.entry).to eq(entry)
    end
  end

  describe '#update' do
    context 'with valid parameters' do
      let(:new_amount) { 25.50 }
      let(:params) { { amount: new_amount } }

      it 'updates the entry' do
        result = service.update(params)

        expect(result.success?).to be true
        expect(result.entry).to eq(entry)
        expect(entry.reload.amount).to eq(new_amount)
      end

      it 'returns success true' do
        result = service.update(params)

        expect(result.success?).to be true
      end

      it 'returns the updated entry' do
        result = service.update(params)

        expect(result.entry).to eq(entry)
        expect(result.entry.amount).to eq(new_amount)
      end

      it 'returns nil errors' do
        result = service.update(params)

        expect(result.errors).to be_nil
      end

      it 'updates multiple attributes' do
        new_date = Date.new(2025, 1, 15)
        params = { amount: 100.0, date: new_date, currency: :usd }

        result = service.update(params)

        expect(result.success?).to be true
        expect(entry.reload.amount).to eq(100.0)
        expect(entry.date.to_date).to eq(new_date)
        expect(entry.currency).to eq('usd')
      end
    end

    context 'with invalid parameters' do
      let(:params) { { amount: -10.0 } }

      it 'does not update the entry' do
        original_amount = entry.amount
        service.update(params)

        expect(entry.reload.amount).to eq(original_amount)
      end

      it 'returns success false' do
        result = service.update(params)

        expect(result.success?).to be false
      end

      it 'returns errors' do
        result = service.update(params)

        expect(result.errors).to be_present
        expect(result.errors).to be_a(ActiveModel::Errors)
      end

      it 'includes validation error messages' do
        result = service.update(params)

        expect(result.errors[:amount]).to include('must be greater than 0')
      end
    end

    context 'when setting debit and credit to the same bucket' do
      let(:params) { { credit_account_id: debit_bucket.id } }

      it 'returns success false' do
        result = service.update(params)

        expect(result.success?).to be false
      end

      it 'returns validation errors' do
        result = service.update(params)

        expect(result.errors).to be_present
        expect(result.errors[:credit_account]).to include('must be different to the debit account')
      end
    end

    context 'when setting amount to nil' do
      let(:params) { { amount: nil } }

      it 'returns success false' do
        result = service.update(params)

        expect(result.success?).to be false
      end

      it 'returns validation errors' do
        result = service.update(params)

        expect(result.errors).to be_present
        expect(result.errors[:amount]).to be_present
      end
    end
  end
end
