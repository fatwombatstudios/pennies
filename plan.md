# Entry Creation User Flow Plan

## Problem Statement

The current entry form allows users to select any bucket for both debit and credit accounts, which can lead to confusion and incorrect entry types. Different transaction types should have specialized flows:

1. **Income**: Real account (debit) → Income bucket (credit)
2. **Expense**: Spending/Savings bucket (debit) → Real account (credit)
3. **Allocation**: Virtual bucket (debit) → Virtual bucket (credit)

## Current State

- Single generic form at `/entries/new` with all buckets available for both debit and credit
- No visual distinction between entry types
- Users must understand double-entry bookkeeping to select correct accounts
- Easy to make mistakes by selecting incompatible account types

## Proposed Solution

### A. Separate Entry Type Routes

Create dedicated routes for each entry type's form, but POST to the standard `create` action:

```ruby
# config/routes.rb
resources :entries do
  collection do
    get :income      # New income entry form
    get :expense     # New expense entry form
    get :allocation  # New allocation entry form
  end
end
```

All forms POST to the standard `POST /entries` route (entries#create).

### B. Controller Actions

Add type-specific GET actions in `EntriesController`, and update the existing `create` action to handle rendering the appropriate form on validation errors:

```ruby
# GET /entries/income
def income
  @entry = Entry.new
  @real_accounts = current_user.account.buckets.where(account_type: 'Real')
  @income_buckets = current_user.account.buckets.where(account_type: 'Income')
end

# GET /entries/expense
def expense
  @entry = Entry.new
  @real_accounts = current_user.account.buckets.where(account_type: 'Real')
  @spending_buckets = current_user.account.buckets.where(account_type: ['Spending', 'Savings'])
end

# GET /entries/allocation
def allocation
  @entry = Entry.new
  @virtual_buckets = current_user.account.buckets.where.not(account_type: 'Real')
end

# POST /entries (modified)
def create
  @entry = Entry.new(entry_params)

  if @entry.save
    redirect_to entries_path, notice: entry_success_message(params[:entry][:form_type])
  else
    # Re-render the appropriate form based on hidden form_type field
    case params[:entry][:form_type]
    when 'income'
      @real_accounts = current_user.account.buckets.where(account_type: 'Real')
      @income_buckets = current_user.account.buckets.where(account_type: 'Income')
      render :income, status: :unprocessable_entity
    when 'expense'
      @real_accounts = current_user.account.buckets.where(account_type: 'Real')
      @spending_buckets = current_user.account.buckets.where(account_type: ['Spending', 'Savings'])
      render :expense, status: :unprocessable_entity
    when 'allocation'
      @virtual_buckets = current_user.account.buckets.where.not(account_type: 'Real')
      render :allocation, status: :unprocessable_entity
    else
      @buckets = current_user.account.buckets
      render :new, status: :unprocessable_entity
    end
  end
end

private

def entry_success_message(form_type)
  case form_type
  when 'income' then "Income recorded successfully."
  when 'expense' then "Expense recorded successfully."
  when 'allocation' then "Allocation completed successfully."
  else "Entry was successfully created."
  end
end
```

### C. Specialized Views

Create type-specific form partials:

**app/views/entries/income.html.erb:**
```erb
<h1>Record Income</h1>

<%= form_with(model: @entry, url: entries_path) do |form| %>
  <%= render "shared/error_messages", object: @entry %>
  <%= form.hidden_field :form_type, value: 'income' %>

  <div>
    <%= form.label :amount, "Income Amount", style: "display: block" %>
    <%= form.number_field :amount, step: 0.01, required: true %>
  </div>

  <div>
    <%= form.label :debit_account_id, "Deposit To (Bank Account)", style: "display: block" %>
    <%= form.select :debit_account_id,
        @real_accounts.collect { |a| [a.name, a.id] },
        { prompt: "Select bank account" } %>
  </div>

  <div>
    <%= form.label :credit_account_id, "Income Category", style: "display: block" %>
    <%= form.select :credit_account_id,
        @income_buckets.collect { |a| [a.name, a.id] },
        { prompt: "Select income category" } %>
  </div>

  <div>
    <%= form.label :date, style: "display: block" %>
    <%= form.date_field :date, value: Date.today %>
  </div>

  <div>
    <%= form.label :currency, style: "display: block" %>
    <%= form.text_field :currency, value: "EUR" %>
  </div>

  <div>
    <%= form.submit "Record Income" %>
  </div>
<% end %>
```

**app/views/entries/expense.html.erb:**
```erb
<h1>Record Expense</h1>

<%= form_with(model: @entry, url: entries_path) do |form| %>
  <%= render "shared/error_messages", object: @entry %>
  <%= form.hidden_field :form_type, value: 'expense' %>

  <div>
    <%= form.label :amount, "Expense Amount", style: "display: block" %>
    <%= form.number_field :amount, step: 0.01, required: true %>
  </div>

  <div>
    <%= form.label :debit_account_id, "Spending Category", style: "display: block" %>
    <%= form.select :debit_account_id,
        @spending_buckets.collect { |a| [a.name, a.id] },
        { prompt: "Select category" } %>
  </div>

  <div>
    <%= form.label :credit_account_id, "Pay From (Bank Account)", style: "display: block" %>
    <%= form.select :credit_account_id,
        @real_accounts.collect { |a| [a.name, a.id] },
        { prompt: "Select bank account" } %>
  </div>

  <div>
    <%= form.label :date, style: "display: block" %>
    <%= form.date_field :date, value: Date.today %>
  </div>

  <div>
    <%= form.label :currency, style: "display: block" %>
    <%= form.text_field :currency, value: "EUR" %>
  </div>

  <div>
    <%= form.submit "Record Expense" %>
  </div>
<% end %>
```

**app/views/entries/allocation.html.erb:**
```erb
<h1>Allocate Between Buckets</h1>

<%= form_with(model: @entry, url: entries_path) do |form| %>
  <%= render "shared/error_messages", object: @entry %>
  <%= form.hidden_field :form_type, value: 'allocation' %>

  <div>
    <%= form.label :amount, "Allocation Amount", style: "display: block" %>
    <%= form.number_field :amount, step: 0.01, required: true %>
  </div>

  <div>
    <%= form.label :debit_account_id, "Transfer From", style: "display: block" %>
    <%= form.select :debit_account_id,
        @virtual_buckets.collect { |a| [a.name, a.id] },
        { prompt: "Select source bucket" } %>
  </div>

  <div>
    <%= form.label :credit_account_id, "Transfer To", style: "display: block" %>
    <%= form.select :credit_account_id,
        @virtual_buckets.collect { |a| [a.name, a.id] },
        { prompt: "Select destination bucket" } %>
  </div>

  <div>
    <%= form.label :date, style: "display: block" %>
    <%= form.date_field :date, value: Date.today %>
  </div>

  <div>
    <%= form.label :currency, style: "display: block" %>
    <%= form.text_field :currency, value: "EUR" %>
  </div>

  <div>
    <%= form.submit "Allocate Funds" %>
  </div>
<% end %>
```

### D. Navigation Updates

Update navigation to provide clear entry points:

```erb
<!-- In app/views/layouts/application.html.erb or navigation partial -->
<nav>
  <%= link_to "Record Income", income_entries_path %>
  <%= link_to "Record Expense", expense_entries_path %>
  <%= link_to "Allocate Funds", allocation_entries_path %>
  <%= link_to "View All Entries", entries_path %>
</nav>
```

### E. Entry Index Enhancement

Update `app/views/entries/index.html.erb` to show entry type badges:

```erb
<% @entries.each do |entry| %>
  <tr>
    <td><%= badge_for_entry_type(entry.entry_type) %></td>
    <td><%= entry.date %></td>
    <td><%= number_to_currency(entry.amount, unit: entry.currency) %></td>
    <td><%= entry.debit_account.name %></td>
    <td><%= entry.credit_account.name %></td>
  </tr>
<% end %>
```

Add helper method:

```ruby
# app/helpers/entries_helper.rb
def badge_for_entry_type(type)
  case type
  when :income
    content_tag(:span, "Income", class: "badge badge-success")
  when :expense
    content_tag(:span, "Expense", class: "badge badge-danger")
  when :allocation
    content_tag(:span, "Allocation", class: "badge badge-info")
  end
end
```

## Benefits of This Approach

1. **User-Friendly**: Clear, purpose-specific forms with appropriate labels
2. **Error Prevention**: Only valid account types shown for each transaction type
3. **Clarity**: Users understand they're recording income, not moving debits/credits
4. **Validation**: Server-side validation ensures entry type matches selected accounts
5. **Extensibility**: Easy to add new entry types or modify existing ones
6. **Maintainability**: Separation of concerns makes code easier to understand

## Implementation Steps

1. Add new routes for income, expense, and allocation GET actions
2. Add controller GET actions (income, expense, allocation)
3. Update the `create` action to handle different entry types on validation errors
4. Create specialized view templates for each entry type (income.html.erb, expense.html.erb, allocation.html.erb)
5. Add helper methods for entry type badges
6. Update navigation to include links to specialized forms
7. Update entry index to display entry types
8. Add RSpec feature tests for each entry flow
9. Optionally deprecate or repurpose the generic `/entries/new` route

## Testing Considerations

Each entry type should have feature tests covering:

- Successful entry creation with valid accounts
- Validation errors when selecting invalid account combinations
- Display of appropriate buckets in select dropdowns
- Correct entry_type calculation after save
- Proper error handling and user feedback

## Alternative Considerations

### Option B: Single Form with JavaScript Filtering

Instead of separate routes, use a single form with JavaScript that:
- Has a "Transaction Type" selector at the top
- Dynamically filters available buckets based on selected type
- Updates labels and help text based on type

**Pros**: Single route, less code duplication
**Cons**: Requires JavaScript, more complex client-side logic, less accessible

**Recommendation**: Start with separate routes (Option A) for simplicity and accessibility. Can add JavaScript enhancements later if desired.

## Scoping Consideration

**IMPORTANT**: All queries must be scoped to `current_user.account`:

```ruby
# Instead of:
@real_accounts = Bucket.where(account_type: 'Real')

# Use:
@real_accounts = current_user.account.buckets.where(account_type: 'Real')
```

This prevents users from seeing or selecting buckets from other accounts.
