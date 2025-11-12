class OfxUploadsController < ApplicationController
  before_action :must_be_signed_in
  before_action :set_real_accounts

  def new
    # Display upload form
  end

  def create
    uploaded_file = params[:ofx_file]
    real_account_id = params[:real_account_id]

    if uploaded_file.blank?
      flash[:alert] = "Please select an OFX file to upload"
      render :new, status: :unprocessable_entity
      return
    end

    if real_account_id.blank?
      flash[:alert] = "Please select a real account"
      render :new, status: :unprocessable_entity
      return
    end

    # Find the real account
    real_account = current_account.buckets.find_by(id: real_account_id, account_type: "Real")
    unless real_account
      flash[:alert] = "Invalid real account selected"
      render :new, status: :unprocessable_entity
      return
    end

    # Ensure system buckets exist
    system_buckets = current_account.ensure_system_buckets!

    # Save uploaded file temporarily
    temp_file = Tempfile.new([ "ofx_upload", ".ofx" ])
    begin
      temp_file.write(uploaded_file.read)
      temp_file.rewind

      # Parse OFX file
      importer = OfxImporterService.new(temp_file.path)
      importer.parse

      # Create entries
      entries_created = 0
      errors = []

      importer.transactions.each do |transaction|
        # Determine debit and credit accounts based on transaction action
        if transaction[:action] == "Income"
          # Income: Real account debited, income bucket credited
          debit_account = real_account
          credit_account = system_buckets[:income]
        else
          # Expense: Expense bucket debited, real account credited
          debit_account = system_buckets[:expense]
          credit_account = real_account
        end

        entry = Entry.new(
          account: current_account,
          date: transaction[:date],
          amount: transaction[:amount],
          currency: transaction[:currency].downcase.to_sym,
          description: transaction[:description],
          debit_account: debit_account,
          credit_account: credit_account
        )

        if entry.save
          entries_created += 1
        else
          errors << "Transaction #{transaction[:fitid]}: #{entry.errors.full_messages.join(", ")}"
        end
      end

      if errors.empty?
        redirect_to entries_path, notice: "Successfully imported #{entries_created} transactions"
      else
        flash.now[:alert] = "Imported #{entries_created} transactions with #{errors.count} errors: #{errors.join("; ")}"
        render :new, status: :unprocessable_entity
      end

    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  private

  def set_real_accounts
    @real_accounts = current_account.buckets.where(account_type: "Real")
  end
end
