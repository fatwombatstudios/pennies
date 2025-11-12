# frozen_string_literal: true

require "nokogiri"

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
    doc = Nokogiri::XML(File.read(file_path))

    # Extract account information
    account_info = extract_account_info(doc)

    # Extract transactions (STMTTRN elements)
    doc.xpath("//STMTTRN").each do |trn|
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

  # Extract account information from the OFX document
  def extract_account_info(doc)
    info = {
      currency: doc.at_xpath("//CURDEF")&.text || "AUD",
      account_type: nil,
      account_id: nil,
      bank_id: nil
    }

    # Check if it's a bank account
    if (bank_acct = doc.at_xpath("//BANKACCTFROM"))
      info[:account_type] = :bank
      info[:account_id] = bank_acct.at_xpath("ACCTID")&.text
      info[:bank_id] = bank_acct.at_xpath("BANKID")&.text
      info[:acct_type] = bank_acct.at_xpath("ACCTTYPE")&.text
    # Check if it's a credit card account
    elsif (cc_acct = doc.at_xpath("//CCACCTFROM"))
      info[:account_type] = :credit_card
      info[:account_id] = cc_acct.at_xpath("ACCTID")&.text
    end

    info
  end

  # Parse a single transaction from STMTTRN element
  def parse_transaction(trn, account_info)
    trntype = trn.at_xpath("TRNTYPE")&.text
    amount = trn.at_xpath("TRNAMT")&.text&.to_f
    date_posted = trn.at_xpath("DTPOSTED")&.text
    fitid = trn.at_xpath("FITID")&.text
    memo = trn.at_xpath("MEMO")&.text

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
