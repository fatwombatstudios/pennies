class BudgetAllocationsController < ApplicationController
  before_action :must_be_signed_in

  def new
    @income_buckets = current_account.buckets.where(account_type: "Income")
    @spending_buckets = current_account.buckets.where(account_type: "Spending")
  end

  def create
    allocations = allocation_params[:allocations] || {}
    income_bucket_id = allocation_params[:income_bucket_id]

    errors = []
    created_entries = []

    # Validate income bucket
    income_bucket = current_account.buckets.find_by(id: income_bucket_id)
    unless income_bucket
      errors << "Income bucket not found"
      render :new, status: :unprocessable_entity and return
    end

    # Calculate total allocation
    total_allocation = allocations.values.map(&:to_f).sum

    # Validate income bucket has sufficient balance
    if income_bucket.balance < total_allocation
      errors << "Insufficient balance in income bucket. Available: #{income_bucket.balance}, Requested: #{total_allocation}"
    end

    # Create entries for each allocation
    allocations.each do |spending_bucket_id, amount|
      next if amount.to_f <= 0

      spending_bucket = current_account.buckets.find_by(id: spending_bucket_id)
      unless spending_bucket
        errors << "Spending bucket #{spending_bucket_id} not found"
        next
      end

      entry = Entry.new(
        account: current_account,
        debit_account_id: income_bucket_id,
        credit_account_id: spending_bucket_id,
        amount: amount.to_f,
        date: Date.today,
        description: "Budget allocation: #{income_bucket.name} → #{spending_bucket.name}",
        currency: :eur
      )

      if entry.save
        created_entries << entry
      else
        errors.concat(entry.errors.full_messages)
      end
    end

    if errors.empty? && created_entries.any?
      redirect_to buckets_path, notice: "Successfully allocated #{created_entries.count} budget(s)"
    else
      # Rollback created entries if there were any errors
      created_entries.each(&:destroy)

      @income_buckets = current_account.buckets.where(account_type: "Income")
      @spending_buckets = current_account.buckets.where(account_type: "Spending")
      @errors = errors
      render :new, status: :unprocessable_entity
    end
  end

  private

  def allocation_params
    params.require(:budget_allocation).permit(:income_bucket_id, allocations: {})
  end
end
