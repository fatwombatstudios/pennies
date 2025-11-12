module EntriesHelper
  def bucket_actions(entry)
    case entry.action
    when :income
      "#{entry.credit_account.name} to #{entry.debit_account.name}"
    when :expense
      "#{entry.debit_account.name} from #{entry.credit_account.name}"
    when :transfer
      # For transfers, show based on bucket type
      if entry.debit_account.real?
        "#{entry.credit_account.name} to #{entry.debit_account.name}"
      else
        "#{entry.debit_account.name} to #{entry.credit_account.name}"
      end
    end
  end
end
