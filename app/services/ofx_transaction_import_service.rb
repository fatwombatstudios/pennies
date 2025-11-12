class OfxTransactionImportService
  include ServiceSignature

  attr_reader :account, :ofx_file, :real_account

  def initialize(account:, ofx_file:, real_account:)
    @account = account
    @ofx_file = ofx_file
    @real_account = real_account
  end

  def import
    system_buckets = ensure_system_buckets
    transactions = parse_ofx_file

    entries_created = 0
    errors = []

    transactions.each do |transaction|
      entry = create_entry_from_transaction(transaction, system_buckets)

      if entry.save
        entries_created += 1
      else
        errors << "Transaction #{transaction[:fitid]}: #{entry.errors.full_messages.join(", ")}"
      end
    end

    if errors.empty?
      returns data: { entries_created: entries_created }
    else
      returns success: false, data: { entries_created: entries_created }, errors: errors
    end
  end

  private

  def ensure_system_buckets
    account.ensure_system_buckets!
  end

  def parse_ofx_file
    temp_file = Tempfile.new([ "ofx_upload", ".ofx" ])
    begin
      temp_file.write(ofx_file.read)
      temp_file.rewind

      importer = OfxImporterService.new(temp_file.path)
      importer.parse
      importer.transactions
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def create_entry_from_transaction(transaction, system_buckets)
    debit_account, credit_account = determine_accounts(transaction, system_buckets)

    Entry.new(
      account: account,
      date: transaction[:date],
      amount: transaction[:amount],
      currency: transaction[:currency].downcase.to_sym,
      description: transaction[:description],
      debit_account: debit_account,
      credit_account: credit_account
    )
  end

  def determine_accounts(transaction, system_buckets)
    if transaction[:action] == "Income"
      # Income: Real account debited, income bucket credited
      [ real_account, system_buckets[:income] ]
    else
      # Expense: Expense bucket debited, real account credited
      [ system_buckets[:expense], real_account ]
    end
  end
end
