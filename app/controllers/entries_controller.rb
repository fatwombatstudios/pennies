class EntriesController < ApplicationController
  before_action :must_be_signed_in
  before_action :set_buckets
  before_action :set_new_entry, except: %i[ upload process_upload ]
  before_action :set_this_entry, only: %i[ show edit update ]
  before_action :set_form_type, only: %i[ new edit ]

  def index
    @entries = current_account.entries.order(date: :desc)
  end

  def show
  end

  def new
  end

  def edit
  end

  # def income
  # end

  # def expense
  # end

  # def budget
  # end

  # def transfer
  # end

  def create
    service = EntryService.new(@entry)
    result = service.update(entry_params)

    respond_to do |format|
      if result.success?
        action_type = params[:entry][:action] || params[:entry][:form_type] || "entry"
        msg = "#{action_type.capitalize} recorded successfully"
        format.html { redirect_to entries_path, notice: msg }
      else
        format.html { render return_action, status: :unprocessable_entity }
      end
    end
  end

  def update
    service = EntryService.new(@entry)
    result = service.update(entry_params)

    respond_to do |format|
      if result.success?
        format.html { redirect_to entries_path, notice: "Entry was successfully updated.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def upload
    # Display upload form
  end

  def process_upload
    uploaded_file = params[:ofx_file]
    real_account_id = params[:real_account_id]

    if uploaded_file.blank?
      flash[:alert] = "Please select an OFX file to upload"
      render :upload, status: :unprocessable_entity
      return
    end

    if real_account_id.blank?
      flash[:alert] = "Please select a real account"
      render :upload, status: :unprocessable_entity
      return
    end

    # Find the real account
    real_account = current_account.buckets.find_by(id: real_account_id, account_type: "Real")
    unless real_account
      flash[:alert] = "Invalid real account selected"
      render :upload, status: :unprocessable_entity
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
        render :upload, status: :unprocessable_entity
      end

    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  private

  def set_this_entry
    @entry = current_account.entries.find(params.expect(:id))
  end

  def set_new_entry
    @entry = Entry.new account: current_account
  end

  def set_buckets
    @buckets = current_account.buckets
    @real_accounts = current_account.buckets.where(account_type: "Real")
    @income_buckets = current_account.buckets.where(account_type: "Income")
    @spending_buckets = current_account.buckets.where(account_type: "Spending")
    @virtual_buckets = current_account.buckets.where.not(account_type: "Real")
  end

  def set_form_type
    @form_type = action_name
  end

  def entry_params
    params.expect(entry: [
      :date,
      :currency,
      :amount,
      :description,
      :action,
      :from_account_id,
      :to_account_id
    ])
  end

  def return_action
    return :new unless params[:entry][:form_type]
    return :new unless [ :new, :edit ].include? params[:entry][:form_type].to_sym

    params[:entry][:form_type].to_sym
  end
end
