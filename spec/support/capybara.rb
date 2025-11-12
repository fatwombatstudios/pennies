require "capybara/rspec"
require "selenium/webdriver"

# Configure Capybara to use headless Chrome for JavaScript tests
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  # Headless mode for CI/local testing
  options.add_argument("--headless=new")

  # Required for running in containerized environments (CI)
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  # Additional stability options
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

# Use headless Chrome for JavaScript-enabled feature tests
Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 5
