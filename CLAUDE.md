# Pennies - Personal Finance Management Application

## Overview

Pennies is a Ruby on Rails 8 application that implements a double-entry bookkeeping system for personal finance management, using the "bucket" or envelope budgeting methodology.

## Core Concept

The application uses double-entry accounting principles where every financial transaction has both a debit and a credit account. It distinguishes between:

- **Real Accounts**: Actual bank accounts, cash, or physical assets
- **Virtual Accounts** (Buckets): Budget categories or spending envelopes

## Data Model

### Key Entities

1. **Account** (`app/models/account.rb`)

   - Top-level container for a household or individual
   - Has many users, buckets, and entries
   - Provides multi-user support for shared accounts

2. **User** (`app/models/user.rb`)

   - Authentication using bcrypt (`has_secure_password`)
   - Belongs to an account
   - Email-based login with password validation

3. **Bucket** (`app/models/bucket.rb`)

   - Named accounts that can be "Real" or "Virtual"
   - Tracks balance based on debit/credit entries
   - Virtual buckets: budget categories (groceries, rent, savings goals)
   - Real buckets: actual bank accounts or cash
   - Balance calculation differs by type (virtual: credits - debits, real: debits - credits)

4. **Entry** (`app/models/entry.rb`)

   - Double-entry transaction with debit and credit accounts
   - Three transaction types:
     - **Income**: Real account debited, virtual account credited
     - **Expense**: Virtual account debited, real account credited
     - **Allocation**: Between virtual accounts (budget reallocation)
   - Includes date, amount, and currency
   - Validates that debit and credit accounts are different

## Technology Stack

### Backend

- **Rails**: 8.0.4 (latest stable)
- **Database**: SQLite3 (2.1+)
- **Authentication**: bcrypt
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable

### Frontend

- **CSS**: Dart Sass
- **JavaScript**: Stimulus + Turbo (Hotwire)
- **Asset Pipeline**: Propshaft + Import Maps

### Infrastructure

- **Web Server**: Puma
- **Deployment**: Kamal (Docker-based)
- **Reverse Proxy**: Thruster

### Testing

- **Framework**: RSpec
- **Factories**: FactoryBot
- **Feature Tests**: Capybara + Selenium WebDriver
- **Security**: Brakeman

## Project Structure

```
app/
├── controllers/      # Request handlers
├── models/          # Domain logic (Account, User, Bucket, Entry)
├── views/           # ERB templates
├── helpers/         # View helpers
├── jobs/            # Background job processing
└── javascript/      # Stimulus controllers
config/              # Rails configuration
db/
├── migrate/         # Database migrations
└── schema.rb        # Current database schema
spec/                # RSpec test suite
├── features/        # Feature/integration tests
├── models/          # Model unit tests
└── requests/        # Request specs
```

## Development Setup

Uses modern Rails conventions with:

- Procfile.dev for development processes
- Docker support via Dockerfile
- RuboCop for code style
- GitHub Actions for CI/CD

## Instructions for Agents

- always lint after making any changes with `bin/rubocop -f github`
- always run tests after any work with `bin/rails db:test:prepare && bundle exec rspec`
- when a command include `worktree`, always start new feature in a new git worktree in a `.trees` folder
