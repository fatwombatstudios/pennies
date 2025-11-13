class OfxUploadsController < ApplicationController
  before_action :must_be_signed_in
  before_action :set_real_accounts

  def new
    @form = OfxUploadForm.new
  end

  def create
    @form = OfxUploadForm.new(form_params)
    @form.account = current_account

    unless @form.valid?
      flash.now[:alert] = @form.errors.full_messages.first
      render :new, status: :unprocessable_entity
      return
    end

    result = OfxTransactionImportService.new(
      account: current_account,
      ofx_file: @form.ofx_file,
      real_account: @form.real_account
    ).import

    if result.success?
      redirect_to entries_path, notice: "Successfully imported #{result.data[:entries_created]} transactions"
    else
      entries_created = result.data[:entries_created]
      errors = result.errors
      flash.now[:alert] = "Imported #{entries_created} transactions with #{errors.count} errors: #{errors.join("; ")}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_real_accounts
    @real_accounts = current_account.buckets.where(account_type: "Real")
  end

  def form_params
    params.permit(:ofx_file, :real_account_id)
  end
end
