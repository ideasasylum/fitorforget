require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET /signup renders signup form" do
    get signup_path
    assert_response :success
    assert_select "form"
  end

  test "GET /signin renders signin form" do
    get signin_path
    assert_response :success
    assert_select "form"
  end

  test "POST /signup returns registration challenge for new email" do
    post create_signup_path, params: { email: "newuser@example.com" }
    assert_response :success
    # Verify we get a Turbo Frame response for registration
    assert_match /turbo-frame/, response.body
  end

  test "POST /signup returns error for existing email" do
    User.create!(email: "existing@example.com")

    post create_signup_path, params: { email: "existing@example.com" }
    assert_response :success
    # Verify we get an error message
    assert_match /already exists/, response.body
  end

  test "POST /signin returns authentication challenge for existing email" do
    user = User.create!(email: "existing@example.com")
    user.credentials.create!(
      external_id: "test_credential_123",
      public_key: "test_public_key",
      sign_count: 0
    )

    post create_signin_path, params: { email: "existing@example.com" }
    assert_response :success
    # Verify we get a Turbo Frame response for authentication
    assert_match /turbo-frame/, response.body
  end

  test "POST /signin returns error for non-existent email" do
    post create_signin_path, params: { email: "nonexistent@example.com" }
    assert_response :success
    # Verify we get an error message
    assert_match /No account found/, response.body
  end

  test "DELETE /logout clears session and redirects" do
    delete logout_path
    assert_redirected_to root_path
    assert_equal "You have been logged out", flash[:notice]
  end
end
