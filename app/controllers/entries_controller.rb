class EntriesController < ApplicationController
  before_action :must_be_signed_in
  before_action :set_buckets
  before_action :set_entry, only: %i[ show edit update ]

  # GET /entries or /entries.json
  def index
    @entries = Entry.all
  end

  # GET /entries/1 or /entries/1.json
  def show
  end

  def new
    @entry = Entry.new
  end

  def edit
  end

  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to entries_path, notice: "Entry was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
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
    @entry = Entry.find(params.expect(:id))
  end

  def set_buckets
    @buckets = Bucket.all
  end

  def entry_params
    params.expect(entry: [ :date, :currency, :amount, :debit_account_id, :credit_account_id ])
  end
end
