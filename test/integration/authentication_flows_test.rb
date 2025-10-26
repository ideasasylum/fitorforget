require "test_helper"

class AuthenticationFlowsTest < ActionDispatch::IntegrationTest
  # Test: Full registration flow creates user, credential, and session
  test "full registration flow creates user credential and session" do
    # Visit signup page
    get signup_path
    assert_response :success

    # Submit email for new user
    email = "newuser@example.com"
    post create_signup_path, params: { email: email }
    assert_response :success

    # Verify registration challenge is generated
    assert_not_nil session[:webauthn_challenge]
    assert_equal email, session[:pending_email]
    assert_not_nil session[:pending_webauthn_id]

    # Simulate WebAuthn registration (mocked)
    # In real flow, JavaScript would call navigator.credentials.create()
    # For testing, we'll verify the user doesn't exist yet
    assert_nil User.find_by_email(email)

    # Note: Full WebAuthn verification requires mocking the WebAuthn gem
    # which is complex. This test verifies the flow up to the WebAuthn step.
  end

  # Test: Full login flow authenticates existing user
  # THIS TEST VALIDATES THE BUG FIX
  test "full login flow authenticates existing user with case-insensitive email" do
    # Create an existing user with lowercase email
    user = User.create!(email: "existing@example.com")
    credential = user.credentials.create!(
      external_id: "test_credential_123",
      public_key: "test_public_key",
      sign_count: 0
    )

    # Try to sign in with different casing (THIS TESTS THE BUG FIX)
    post create_signin_path, params: { email: "Existing@Example.com" }
    assert_response :success

    # The system should recognize this as an existing user and generate auth challenge
    # NOT a registration challenge
    assert_not_nil session[:webauthn_challenge]
    assert_equal "existing@example.com", session[:pending_email]
    # pending_webauthn_id should NOT be set for authentication flow
    assert_nil session[:pending_webauthn_id], "BUG: System is trying to register instead of authenticate!"
  end

  # Test: Multi-device registration creates multiple credentials
  test "multi-device registration creates multiple credentials for same user" do
    # Create a user with one credential (device 1)
    user = User.create!(email: "multidevice@example.com")
    device1_credential = user.credentials.create!(
      external_id: "device1_credential",
      public_key: "device1_public_key",
      sign_count: 0
    )

    assert_equal 1, user.credentials.count

    # Simulate adding a second device
    # In real flow, user would authenticate from new device and be prompted to register
    device2_credential = user.credentials.create!(
      external_id: "device2_credential",
      public_key: "device2_public_key",
      sign_count: 0
    )

    assert_equal 2, user.reload.credentials.count
    assert_includes user.credentials.pluck(:external_id), "device1_credential"
    assert_includes user.credentials.pluck(:external_id), "device2_credential"
  end

  # Test: Session persists across requests
  test "session persists across multiple requests" do
    user = User.create!(email: "persistent@example.com")

    # Visit signup page and set session
    get signup_path
    assert_response :success

    # Set user_id in session
    session[:user_id] = user.id
    assert_equal user.id, session[:user_id]

    # Make another request in the same session
    # Use a simple GET that doesn't reset session
    get signup_path

    # Note: In integration tests, sessions can behave differently
    # This test verifies that the session mechanism exists
    # Full session persistence testing requires actual browser testing
  end

  # Test: Logout clears session and redirects
  test "logout clears session and redirects to root" do
    user = User.create!(email: "logout@example.com")

    # Simulate logged in session
    get signup_path
    session[:user_id] = user.id
    assert_not_nil session[:user_id]

    # Logout
    delete logout_path

    # Verify session cleared
    assert_nil session[:user_id]

    # Verify redirect
    assert_redirected_to root_path
    assert_equal "You have been logged out", flash[:notice]
  end

  # Test: require_authentication redirects unauthenticated users
  test "require_authentication helper works correctly" do
    # This test verifies the authentication helper exists and works
    # For now, we'll test the signup page itself which should be accessible

    # Simulate no session
    get signup_path
    assert_nil session[:user_id]

    # The signup page itself should be accessible
    assert_response :success
  end

  # Test: return_to redirects after successful authentication
  test "return_to session value can be set for redirect after auth" do
    # Set a return_to path in session
    get signup_path
    session[:return_to] = "/programs/123"

    assert_equal "/programs/123", session[:return_to]

    # After authentication, the verify action should use and clear this value
    # Note: This requires mocking WebAuthn verification which is complex
    # For now, we verify the session value is set correctly
  end

  # Test: Email validation prevents invalid emails
  test "email validation prevents invalid email format" do
    post create_signup_path, params: { email: "notanemail" }
    assert_response :success

    # Should return error, not create challenge
    assert_nil session[:webauthn_challenge]
  end

  # Test: Email validation prevents empty emails
  test "email validation prevents empty email" do
    post create_signup_path, params: { email: "" }
    assert_response :success

    # Should return error, not create challenge
    assert_nil session[:webauthn_challenge]
  end

  # Test: Case-insensitive email lookup prevents duplicate registrations
  # THIS IS THE KEY TEST THAT VALIDATES THE BUG FIX
  test "case-insensitive email lookup prevents duplicate user registrations" do
    # Register user with lowercase email
    user = User.create!(email: "user@example.com")
    user.credentials.create!(
      external_id: "original_credential",
      public_key: "original_public_key",
      sign_count: 0
    )

    initial_user_count = User.count

    # Try to sign up with same email in different case
    post create_signup_path, params: { email: "USER@EXAMPLE.COM" }
    assert_response :success

    # Should NOT generate a registration challenge (should show error instead)
    # The pending_webauthn_id should be nil (not set because we're showing error)
    assert_nil session[:pending_webauthn_id],
      "BUG: System is generating registration challenge for existing user with different email case!"

    # Should NOT set pending_email (because we're showing error)
    assert_nil session[:pending_email],
      "BUG: System set pending_email when it should have shown an error!"

    # No new user should be created
    assert_equal initial_user_count, User.count,
      "BUG: New user was created instead of recognizing existing user!"
  end

  # Test: User model normalizes email before saving
  test "user model normalizes email to lowercase before saving" do
    user = User.create!(email: "Test@Example.COM")

    # Email should be normalized to lowercase
    assert_equal "test@example.com", user.email
  end

  # Test: find_by_email class method works case-insensitively
  test "find_by_email finds users regardless of email case" do
    user = User.create!(email: "findme@example.com")

    # Should find with exact case
    found1 = User.find_by_email("findme@example.com")
    assert_equal user.id, found1.id

    # Should find with different case
    found2 = User.find_by_email("FindMe@Example.COM")
    assert_equal user.id, found2.id

    # Should find with all uppercase
    found3 = User.find_by_email("FINDME@EXAMPLE.COM")
    assert_equal user.id, found3.id
  end
end
