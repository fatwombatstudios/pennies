class EntriesController < ApplicationController
  before_action :must_be_signed_in
  before_action :set_buckets
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
        msg = "#{(params[:entry][:form_type] || "entry").capitalize} recorded successfully"
        format.html { redirect_to entries_path, notice: msg }
      else
        return_action = (params[:entry][:form_type] || "new").to_sym
        format.html { render return_action, status: :unprocessable_entity }
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
    @real_accounts = current_account.buckets.where(account_type: "Real")
    @income_buckets = current_account.buckets.where(account_type: "Income")
    @spending_buckets = current_account.buckets.where(account_type: [ "Spending", "Savings" ])
    @virtual_buckets = current_account.buckets.where.not(account_type: "Real")
  end

  def entry_params
    params.expect(entry: [ :date, :currency, :amount, :debit_account_id, :credit_account_id ])
  end
end
