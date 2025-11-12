class EntryService
  include ServiceSignature

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def update(params)
    transformed_params = transform_params(params)
    entry.assign_attributes transformed_params

    if entry.save
      returns data: entry
    else
      returns success: false, data: entry, errors: entry.errors
    end
  end

  private

  def transform_params(params)
    return params.except(:action) unless params[:action].present?

    case params[:action]
    when "income"
      transform_income_params(params)
    when "expense"
      transform_expense_params(params)
    when "transfer"
      transform_transfer_params(params)
    else
      params.except(:action)
    end
  end

  def transform_income_params(params)
    # Income: from (income bucket) is credited, to (real account) is debited
    params.except(:action, :from_account_id, :to_account_id).merge(
      credit_account_id: params[:from_account_id],
      debit_account_id: params[:to_account_id]
    )
  end

  def transform_expense_params(params)
    # Expense: from (spending bucket) is debited, to (real account) is credited
    params.except(:action, :from_account_id, :to_account_id).merge(
      debit_account_id: params[:from_account_id],
      credit_account_id: params[:to_account_id]
    )
  end

  def transform_transfer_params(params)
    from_bucket = Bucket.find_by(id: params[:from_account_id])

    # For real-to-real: from is credit (money leaves), to is debit (money arrives)
    # For virtual-to-virtual: from is debit (budget decreases), to is credit (budget increases)
    if from_bucket&.real?
      params.except(:action, :from_account_id, :to_account_id).merge(
        credit_account_id: params[:from_account_id],
        debit_account_id: params[:to_account_id]
      )
    else
      params.except(:action, :from_account_id, :to_account_id).merge(
        debit_account_id: params[:from_account_id],
        credit_account_id: params[:to_account_id]
      )
    end
  end
end
