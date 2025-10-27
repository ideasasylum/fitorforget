# == Schema Information
#
# Table name: credentials
#
#  id          :integer          not null, primary key
#  nickname    :string
#  public_key  :text             not null
#  sign_count  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :string           not null
#  user_id     :integer          not null
#
require "test_helper"

class CredentialTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com")
  end

  test "should not save credential without external_id" do
    credential = Credential.new(user: @user, public_key: "test_key")
    assert_not credential.save, "Saved credential without external_id"
  end

  test "should not save credential without public_key" do
    credential = Credential.new(user: @user, external_id: "test_id")
    assert_not credential.save, "Saved credential without public_key"
  end

  test "should not save credential without user" do
    credential = Credential.new(external_id: "test_id", public_key: "test_key")
    assert_not credential.save, "Saved credential without user"
  end

  test "should not save credential with duplicate external_id" do
    Credential.create!(user: @user, external_id: "duplicate_id", public_key: "key1")
    duplicate_credential = Credential.new(user: @user, external_id: "duplicate_id", public_key: "key2")
    assert_not duplicate_credential.save, "Saved credential with duplicate external_id"
  end

  test "should belong to user" do
    credential = Credential.new(user: @user, external_id: "test_id", public_key: "test_key")
    assert_respond_to credential, :user, "Credential does not have user association"
  end

  test "should have default sign_count of 0" do
    credential = Credential.create!(user: @user, external_id: "test_id", public_key: "test_key")
    assert_equal 0, credential.sign_count, "Default sign_count is not 0"
  end

  test "should allow setting sign_count" do
    credential = Credential.create!(user: @user, external_id: "test_id", public_key: "test_key", sign_count: 5)
    assert_equal 5, credential.sign_count, "sign_count was not set correctly"
  end
end
