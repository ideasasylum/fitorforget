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
      post signin_path, params: { email: user.email }
      # Note: Full WebAuthn sign-in requires browser interaction
      # For controller tests, we can manually set the session
      session[:user_id] = user.id if defined?(session)
    end
  end
end
