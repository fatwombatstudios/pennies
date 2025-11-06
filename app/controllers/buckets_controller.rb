class BucketsController < ApplicationController
  layout "desktop"

  before_action :must_be_signed_in
  before_action :set_buckets
  before_action :set_bucket, only: %i[ show edit update ]

  def index
    @buckets = current_account.buckets
  end

  def show
    debits = current_account.entries.where(debit_account: @bucket)
    credits = current_account.entries.where(credit_account: @bucket)

    @entries = debits + credits
  end

  def new
    @bucket = Bucket.new account_id: current_account.id
  end

  def edit
  end

  def create
    @bucket = Bucket.new bucket_params.merge(account_id: current_account.id)

    respond_to do |format|
      if @bucket.save
        format.html { redirect_to buckets_path, notice: "Bucket was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bucket.update(bucket_params)
        format.html { redirect_to buckets_path, notice: "Bucket was successfully updated.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_buckets
    @buckets = current_account.buckets
  end

  def set_bucket
    @bucket = @buckets.find(params.expect(:id))
  end

  def bucket_params
    params.expect(bucket: [ :name, :description, :account_type ])
  end
end
