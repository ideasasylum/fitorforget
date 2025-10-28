ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Helper method to sign in a user for testing
    def sign_in_as(user)
      # Create a session in the database for Active Record session store
      session_id = SecureRandom.hex(16)
      session_data = {user_id: user.id}

      # Create session record in database
      ActiveRecord::SessionStore::Session.create!(
        session_id: session_id,
        data: session_data
      )

      # Set the session cookie for subsequent requests
      cookies[Rails.application.config.session_options[:key]] = session_id
    end
  end

  class SystemTestCase
    # Helper method to sign in a user for system testing
    def sign_in_as(user)
      # Create a session in the database for Active Record session store
      session_id = SecureRandom.hex(16)
      session_data = {user_id: user.id}

      # Create session record in database
      ActiveRecord::SessionStore::Session.create!(
        session_id: session_id,
        data: session_data
      )

      # Visit root to establish browser context
      visit root_path

      # Set the session cookie using JavaScript via Playwright
      session_cookie_name = Rails.application.config.session_options[:key]
      page.execute_script("document.cookie = '#{session_cookie_name}=#{session_id}; path=/; SameSite=Lax'")
    end
  end
end
