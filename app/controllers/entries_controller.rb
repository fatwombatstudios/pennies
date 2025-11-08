class EntriesController < ApplicationController
  before_action :must_be_signed_in
  before_action :set_buckets
  before_action :set_bucket_collections, only: %i[ income expense allocation create ]
  before_action :set_entry, only: %i[ show edit update ]

  # GET /entries or /entries.json
  def index
    @entries = current_account.entries
  end

  # GET /entries/1 or /entries/1.json
  def show
  end

  def new
    @entry = Entry.new
  end

  def edit
  end

  def income
    @entry = Entry.new
  end

  def expense
    @entry = Entry.new
  end

  def allocation
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to entries_path, notice: entry_success_message(params[:entry][:form_type]) }
      else
        # Re-render the appropriate form based on hidden form_type field
        case params[:entry][:form_type]
        when "income"
          format.html { render :income, status: :unprocessable_entity }
        when "expense"
          format.html { render :expense, status: :unprocessable_entity }
        when "allocation"
          format.html { render :allocation, status: :unprocessable_entity }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to entries_path, notice: "Entry was successfully updated.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_entry
    @entry = current_account.entries.find(params.expect(:id))
  end

  def set_buckets
    @buckets = current_account.buckets
  end

  def set_bucket_collections
    @real_accounts = current_account.buckets.where(account_type: "Real")
    @income_buckets = current_account.buckets.where(account_type: "Income")
    @spending_buckets = current_account.buckets.where(account_type: [ "Spending", "Savings" ])
    @virtual_buckets = current_account.buckets.where.not(account_type: "Real")
  end

  def entry_params
    params.expect(entry: [ :date, :currency, :amount, :debit_account_id, :credit_account_id ])
  end

  def entry_success_message(form_type)
    case form_type
    when "income" then "Income recorded successfully."
    when "expense" then "Expense recorded successfully."
    when "allocation" then "Allocation completed successfully."
    else "Entry was successfully created."
    end
  end
end
