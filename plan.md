# Double Entry Accounting Implementation Plan

## Overview

Transform the current single-entry transaction system into a proper double-entry accounting system. This will enable accurate financial tracking, balance verification, and comprehensive reporting.

## Current State

The application currently uses a simplified transaction model:
- `Tx` model with `date`, `amount`, `currency`, and `description`
- `Tag` model for categorization
- Single-entry recording (transactions record money in/out without counterparty accounts)

## Double Entry Accounting Principles

In double-entry accounting:
1. Every transaction affects at least two accounts
2. Total debits must equal total credits for every transaction
3. The accounting equation must always balance: **Assets = Liabilities + Equity**
4. This provides built-in error checking and audit trails

## Proposed Architecture

### 1. Chart of Accounts

Create a hierarchical account structure:

```
Assets
├── Current Assets
│   ├── Cash
│   ├── Bank Accounts
│   └── Accounts Receivable
└── Fixed Assets
    └── Property & Equipment

Liabilities
├── Current Liabilities
│   ├── Accounts Payable
│   └── Credit Cards
└── Long-term Liabilities
    └── Loans

Equity
├── Owner's Equity
├── Retained Earnings
└── Drawings

Income
├── Operating Income
│   ├── Sales
│   └── Service Income
└── Other Income
    └── Interest Income

Expenses
├── Operating Expenses
│   ├── Salaries
│   ├── Rent
│   ├── Utilities
│   └── Supplies
└── Other Expenses
    ├── Interest Expense
    └── Depreciation
```

### 2. Database Schema Changes

#### New Models

**Account**
```ruby
# Represents accounts in the chart of accounts
- id: integer
- code: string (e.g., "1000", "1100") - unique, indexed
- name: string (e.g., "Cash", "Bank Account")
- account_type: enum [:asset, :liability, :equity, :income, :expense]
- parent_id: integer (self-referential for hierarchy)
- normal_balance: enum [:debit, :credit]
- active: boolean (default: true)
- description: text
- timestamps
```

**Entry (Journal Entry)**
```ruby
# Replaces the current Tx model
- id: integer
- entry_number: string (unique identifier, e.g., "JE-2024-001")
- date: datetime (transaction date)
- description: string (memo/description)
- reference: string (external reference like invoice number)
- posted: boolean (default: false) - prevents editing once posted
- reversed: boolean (default: false) - marks reversed entries
- reversal_of_id: integer (links to original entry if this is a reversal)
- timestamps
```

**LineItem (Journal Entry Lines)**
```ruby
# The individual debit/credit lines within an entry
- id: integer
- entry_id: integer (foreign key to entries)
- account_id: integer (foreign key to accounts)
- debit: decimal (precision: 19, scale: 4)
- credit: decimal (precision: 19, scale: 4)
- description: string (line-specific memo)
- timestamps

# Constraints:
# - Either debit OR credit must be non-zero (not both)
# - Both debit and credit cannot be non-zero simultaneously
# - Debits and credits must balance for each entry
```

**Tag** (Updated)
```ruby
# Modified to tag entries instead of transactions
- id: integer
- name: string
- entry_id: integer (changed from tx_id)
- timestamps
```

### 3. Model Validations and Business Rules

**Account Model**
- Code must be unique
- Name must be present
- Account type must be valid
- Parent account must exist if specified
- Prevent deletion if line items exist

**Entry Model**
- Date must be present and not in the future (configurable)
- Must have at least 2 line items
- Total debits must equal total credits
- Cannot be edited once posted
- Cannot be deleted once posted (must be reversed instead)

**LineItem Model**
- Must belong to an account and entry
- Either debit OR credit must be > 0 (not both, not neither)
- Amount must match the entry's currency (if tracking multi-currency)

### 4. Common Transaction Patterns

#### Example 1: Record Income (Sale/Service)
```
Debit:  Bank Account    $1,000
Credit: Sales Revenue   $1,000
```

#### Example 2: Record Expense (Rent Payment)
```
Debit:  Rent Expense    $2,000
Credit: Bank Account    $2,000
```

#### Example 3: Owner Investment
```
Debit:  Bank Account    $10,000
Credit: Owner's Equity  $10,000
```

#### Example 4: Purchase on Credit
```
Debit:  Supplies        $500
Credit: Accounts Payable $500
```

### 5. Migration Strategy

#### Phase 1: Create New Schema
1. Create `accounts` table with seed data for basic chart of accounts
2. Create `entries` table
3. Create `line_items` table
4. Update `tags` table to reference entries

#### Phase 2: Data Migration
1. Create default accounts if they don't exist
2. Migrate existing `txs` records to new `entries` format
   - Positive amounts: Debit Bank, Credit Income
   - Negative amounts: Debit Expense, Credit Bank
3. Preserve transaction history and metadata
4. Migrate tags to new structure

#### Phase 3: Deprecate Old Schema
1. Add deprecation warnings to Tx model
2. Update controllers and views to use new models
3. Update tests
4. Remove Tx model once migration is complete

### 6. Key Features to Implement

**Trial Balance Report**
- Sum all debits and credits by account
- Verify debits = credits
- Show account balances

**Balance Sheet**
- Assets = Liabilities + Equity
- Point-in-time financial position
- Group by account type and hierarchy

**Income Statement (P&L)**
- Income - Expenses = Net Income/Loss
- Period-based reporting
- Show revenue and expense categories

**General Ledger**
- Complete transaction history by account
- Show running balance
- Filter by date range, account, or entry

**Journal Entry Interface**
- Form for creating multi-line entries
- Auto-calculate remaining amount to balance
- Validation before posting
- Ability to reverse entries

### 7. Testing Strategy

**Unit Tests**
- Account hierarchy and calculations
- Entry validation (balanced entries)
- LineItem constraints (debit XOR credit)
- Account balance calculations

**Integration Tests**
- Complete transaction workflows
- Report generation accuracy
- Data migration integrity

**System Tests**
- UI for creating entries
- Report viewing and filtering
- Account management

### 8. Implementation Order

1. **Setup Phase**
   - [ ] Create Account model and migration
   - [ ] Create Entry model and migration
   - [ ] Create LineItem model and migration
   - [ ] Update Tag associations
   - [ ] Seed chart of accounts

2. **Core Features**
   - [ ] Account CRUD operations
   - [ ] Entry creation with line items
   - [ ] Entry posting/locking mechanism
   - [ ] Entry reversal functionality
   - [ ] Balance calculations

3. **Reporting**
   - [ ] Trial Balance report
   - [ ] Balance Sheet report
   - [ ] Income Statement report
   - [ ] General Ledger view

4. **Migration**
   - [ ] Write data migration script
   - [ ] Test migration with existing data
   - [ ] Execute migration
   - [ ] Update views and controllers
   - [ ] Update tests

5. **Polish**
   - [ ] Entry templates for common transactions
   - [ ] Quick entry shortcuts
   - [ ] Account search and filtering
   - [ ] Export functionality
   - [ ] Audit trail

### 9. Technical Considerations

**Performance**
- Index account codes and entry dates
- Consider caching account balances
- Optimize report queries with database views
- Use eager loading for nested associations

**Data Integrity**
- Database-level constraints on line item debit/credit
- Check constraints to ensure balanced entries
- Foreign key constraints
- Prevent deletion of accounts with history

**Multi-Currency Support**
- Store currency per entry
- Track exchange rates
- Convert to base currency for reports
- Handle currency gains/losses

**Audit Trail**
- Log all entry modifications
- Track who posted/reversed entries
- Maintain reversal chain links
- Consider paper_trail gem for versioning

## Resources

- [Double-Entry Bookkeeping on Wikipedia](https://en.wikipedia.org/wiki/Double-entry_bookkeeping)
- [Plutus Gem](https://github.com/mbulat/plutus) - Ruby double-entry accounting library
- [Double Entry Gem](https://github.com/envato/double_entry) - Envato's double-entry library
- [Plain Text Accounting](https://plaintextaccounting.org/) - Concepts and tools
- [Accounting for Developers series](https://www.moderntreasury.com/journal/accounting-for-developers-part-i)

## Next Steps

1. Review and validate this plan
2. Set up development branch
3. Create first migration for accounts table
4. Implement Account model with tests
5. Proceed through implementation order
