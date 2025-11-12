class EntriesController < ApplicationController
  FORM_TYPES = %i[ new edit income expense budget transfer]

  before_action :must_be_signed_in
  before_action :set_buckets
  before_action :set_new_entry
  before_action :set_this_entry, only: %i[ show edit update ]
  before_action :set_form_type, only: FORM_TYPES

  def index
    @entries = current_account.entries.order(date: :desc)
  end

  def show
  end

  def new
  end

  def edit
  end

  def income
  end

  def expense
  end

  def budget
  end

  def transfer
  end

  def create
    service = EntryService.new(@entry)
    result = service.update(entry_params)

    respond_to do |format|
      if result.success?
        msg = "#{(params[:entry][:form_type] || "entry").capitalize} recorded successfully"
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
    @spending_buckets = current_account.buckets.where(account_type: [ "Spending", "Savings" ])
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
      :debit_account_id,
      :credit_account_id,
      :action,
      :income_account_id,
      :into_account_id,
      :bucket_account_id,
      :from_account_id,
      :to_account_id
    ])
  end

  def return_action
    return :new unless params[:entry][:form_type]
    return :new unless FORM_TYPES.include? params[:entry][:form_type].to_sym

    params[:entry][:form_type].to_sym
  end
end
