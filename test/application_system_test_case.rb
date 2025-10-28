require "test_helper"

# Register custom Playwright driver for Capybara
Capybara.register_driver :wombat_playwright do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: ENV["PLAYWRIGHT_BROWSER"]&.to_sym || :chromium,
    headless: (false unless ENV["CI"] || ENV["PLAYWRIGHT_HEADLESS"]))
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :wombat_playwright
end
