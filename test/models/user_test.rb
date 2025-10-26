require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    user = User.new
    assert_not user.save, "Saved the user without an email"
  end

  test "should not save user with duplicate email" do
    User.create!(email: "test@example.com")
    duplicate_user = User.new(email: "test@example.com")
    assert_not duplicate_user.save, "Saved user with duplicate email"
  end

  test "should enforce case-insensitive email uniqueness" do
    User.create!(email: "test@example.com")
    duplicate_user = User.new(email: "TEST@EXAMPLE.COM")
    assert_not duplicate_user.save, "Saved user with duplicate email in different case"
  end

  test "should not save user without @ in email" do
    user = User.new(email: "notanemail")
    assert_not user.save, "Saved user with invalid email format"
  end

  test "should generate webauthn_id on create" do
    user = User.create!(email: "test@example.com")
    assert_not_nil user.webauthn_id, "webauthn_id was not generated"
    assert user.webauthn_id.length > 0, "webauthn_id is empty"
  end

  test "should have many credentials" do
    user = User.create!(email: "test@example.com")
    assert_respond_to user, :credentials, "User does not have credentials association"
  end

  test "should destroy associated credentials when user is destroyed" do
    user = User.create!(email: "test@example.com")
    credential = user.credentials.create!(
      external_id: "test_credential_123",
      public_key: "test_public_key",
      sign_count: 0
    )

    assert_difference "Credential.count", -1 do
      user.destroy
    end
  end

  # NEW TEST: Email normalization callback
  test "should normalize email to lowercase before validation" do
    user = User.create!(email: "Test@Example.COM")
    assert_equal "test@example.com", user.email
  end

  # NEW TEST: Email normalization with whitespace
  test "should strip whitespace from email before validation" do
    user = User.create!(email: "  test@example.com  ")
    assert_equal "test@example.com", user.email
  end
end
