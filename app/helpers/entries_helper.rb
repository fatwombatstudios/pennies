module EntriesHelper
  def bucket_actions(entry)
    case entry.action
    when :income
      # Real -> Virtual
      "#{entry.debit_account.name} → #{entry.credit_account.name}"
    when :expense
      # Virtual -> Real
      "#{entry.debit_account.name} → #{entry.credit_account.name}"
    when :transfer
      # For transfers, show based on bucket type
      if entry.debit_account.real?
        # Real to Real: show credit -> debit
        "#{entry.credit_account.name} → #{entry.debit_account.name}"
      else
        # Virtual to Virtual: show debit -> credit
        "#{entry.debit_account.name} → #{entry.credit_account.name}"
      end
    end
  end
end
