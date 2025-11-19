# frozen_string_literal: true

require "ox"

# Service to import OFX (Open Financial Exchange) files and convert them to Entry format
# Supports both bank accounts (BANKMSGSRSV1) and credit card accounts (CREDITCARDMSGSRSV1)
class OfxImporterService
  attr_reader :file_path, :transactions

  def initialize(file_path)
    @file_path = file_path
    @transactions = []
  end

  # Parse the OFX file and extract transactions
  def parse
    doc = Ox.load(File.read(file_path), mode: :generic)

    # Extract account information
    account_info = extract_account_info(doc)

    # Extract transactions (STMTTRN elements)
    find_elements(doc, "STMTTRN").each do |trn|
      transaction = parse_transaction(trn, account_info)
      @transactions << transaction if transaction
    end

    self
  end

  # Print all transactions to screen
  def print_transactions
    puts "\n#{"=" * 80}"
    puts "OFX IMPORT: #{file_path}"
    puts "=" * 80
    puts "Found #{transactions.count} transactions\n\n"

    transactions.each_with_index do |trn, index|
      puts "Transaction ##{index + 1}"
      puts "-" * 40
      puts "Date:           #{trn[:date]}"
      puts "Amount:         #{format_amount(trn[:amount])} #{trn[:currency]}"
      puts "Type:           #{trn[:type]}"
      puts "Action:         #{trn[:action]}"
      puts "Description:    #{trn[:description]}"
      puts "FITID:          #{trn[:fitid]}"
      puts "Debit Account:  #{trn[:debit_account]}"
      puts "Credit Account: #{trn[:credit_account]}"
      puts ""
    end

    puts "=" * 80
    puts "Summary: #{transactions.count} transactions totaling #{format_amount(total_amount)} #{transactions.first&.dig(:currency) || "AUD"}"
    puts "=" * 80
    puts ""
  end

  private

  # Helper method to find all elements with a given name recursively
  def find_elements(node, name, results = [])
    return results unless node.respond_to?(:nodes)

    node.nodes.each do |child|
      results << child if child.respond_to?(:value) && child.value == name
      find_elements(child, name, results)
    end

    results
  end

  # Helper method to find first element with a given name
  def find_element(node, name)
    return nil unless node.respond_to?(:nodes)

    node.nodes.each do |child|
      return child if child.respond_to?(:value) && child.value == name
      if (found = find_element(child, name))
        return found
      end
    end

    nil
  end

  # Get text content from an element
  def element_text(node, name)
    element = find_element(node, name)
    return nil unless element&.respond_to?(:nodes)

    element.nodes.find { |n| n.is_a?(String) }
  end

  # Extract account information from the OFX document
  def extract_account_info(doc)
    info = {
      currency: element_text(doc, "CURDEF") || "AUD",
      account_type: nil,
      account_id: nil,
      bank_id: nil
    }

    # Check if it's a bank account
    if (bank_acct = find_element(doc, "BANKACCTFROM"))
      info[:account_type] = :bank
      info[:account_id] = element_text(bank_acct, "ACCTID")
      info[:bank_id] = element_text(bank_acct, "BANKID")
      info[:acct_type] = element_text(bank_acct, "ACCTTYPE")
    # Check if it's a credit card account
    elsif (cc_acct = find_element(doc, "CCACCTFROM"))
      info[:account_type] = :credit_card
      info[:account_id] = element_text(cc_acct, "ACCTID")
    end

    info
  end

  # Parse a single transaction from STMTTRN element
  def parse_transaction(trn, account_info)
    trntype = element_text(trn, "TRNTYPE")
    amount = element_text(trn, "TRNAMT")&.to_f
    date_posted = element_text(trn, "DTPOSTED")
    fitid = element_text(trn, "FITID")
    memo = element_text(trn, "MEMO")

    return nil unless amount && date_posted

    # Parse date (YYYYMMDD format)
    date = Date.parse(date_posted[0..7])

    # Determine the action and accounts based on transaction type and amount
    action, debit_account, credit_account = determine_entry_details(
      trntype,
      amount,
      account_info
    )

    {
      date: date,
      amount: amount.abs,
      currency: account_info[:currency],
      type: trntype,
      action: action,
      description: memo,
      fitid: fitid,
      debit_account: debit_account,
      credit_account: credit_account
    }
  end

  # Determine the entry action and which accounts to debit/credit
  # Based on the Entry model's double-entry logic:
  # - Income: Real account debited, virtual account credited
  # - Expense: Virtual account debited, real account credited
  # - Transfer: Real to real OR virtual to virtual
  def determine_entry_details(trntype, amount, account_info)
    real_account = account_info[:account_type] == :credit_card ? "Credit Card" : "Bank Account"

    case trntype
    when "CREDIT", "DIRECTDEP"
      # Money coming IN to the account (Income)
      # Debit real account (increase asset), Credit income bucket
      [ "Income", real_account, "Income: #{trntype}" ]
    when "DEBIT"
      # Money going OUT of the account (Expense)
      # In OFX, negative amounts are shown for debits
      if amount.negative?
        [ "Expense", "Expense: Unknown", real_account ]
      else
        # Positive debit (unusual, but handle it as income)
        [ "Income", real_account, "Income: #{trntype}" ]
      end
    when "OTHER"
      # Could be income or transfer - check amount sign
      if amount.positive?
        [ "Income", real_account, "Income: #{trntype}" ]
      else
        [ "Expense", "Expense: Unknown", real_account ]
      end
    else
      # Default handling for unknown types
      if amount.positive?
        [ "Income", real_account, "Income: #{trntype}" ]
      else
        [ "Expense", "Expense: Unknown", real_account ]
      end
    end
  end

  # Format amount for display
  def format_amount(amount)
    format("%.2f", amount)
  end

  # Calculate total of all transactions
  def total_amount
    transactions.sum { |t| t[:amount] * (t[:action] == "Income" ? 1 : -1) }
  end
end
