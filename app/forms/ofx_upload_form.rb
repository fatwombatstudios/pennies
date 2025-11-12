class OfxUploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :ofx_file
  attribute :real_account_id, :integer
  attr_accessor :account

  validates :ofx_file, presence: { message: "Please select an OFX file to upload" }
  validates :real_account_id, presence: { message: "Please select a real account" }
  validate :real_account_must_exist

  def real_account
    return nil unless account && real_account_id

    @real_account ||= account.buckets.find_by(id: real_account_id, account_type: "Real")
  end

  private

  def real_account_must_exist
    if real_account_id.present? && real_account.nil?
      errors.add(:real_account_id, "Invalid real account selected")
    end
  end
end
