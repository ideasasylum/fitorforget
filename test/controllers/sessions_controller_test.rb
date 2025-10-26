require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET /auth renders auth form" do
    get auth_path
    assert_response :success
    assert_select "form"
  end

  test "POST /auth/check returns registration challenge for new email" do
    post auth_check_path, params: { email: "newuser@example.com" }
    assert_response :success
    # Verify we get a Turbo Frame response for registration
    assert_match /turbo-frame/, response.body
  end

  test "POST /auth/check returns authentication challenge for existing email" do
    user = User.create!(email: "existing@example.com")
    user.credentials.create!(
      external_id: "test_credential_123",
      public_key: "test_public_key",
      sign_count: 0
    )

    post auth_check_path, params: { email: "existing@example.com" }
    assert_response :success
    # Verify we get a Turbo Frame response for authentication
    assert_match /turbo-frame/, response.body
  end

  test "POST /auth/verify creates session on valid credential" do
    # This test will be expanded when we implement the verify action
    # For now, we just test that the route exists
    post auth_verify_path, params: {
      email: "test@example.com",
      credential_response: "test_response"
    }
    assert_response :redirect
  end

  test "DELETE /logout clears session and redirects" do
    user = User.create!(email: "test@example.com")
    # Simulate logged in session
    post auth_path, params: { user_id: user.id }
    session[:user_id] = user.id

    delete logout_path
    assert_nil session[:user_id]
    assert_redirected_to root_path
    assert_equal "You have been logged out", flash[:notice]
  end
end
