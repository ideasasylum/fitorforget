require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com")
  end

  test "should display Dashboard link in navigation for authenticated users" do
    sign_in_as(@user)

    get dashboard_path
    assert_response :success
    assert_select "nav a[href=?]", dashboard_path, text: "Dashboard"
  end

  test "should not display Dashboard link for unauthenticated users" do
    get root_path
    assert_response :success
    assert_select "nav a[href=?]", dashboard_path, count: 0
  end

  test "Dashboard link should navigate correctly" do
    sign_in_as(@user)

    get dashboard_path
    assert_response :success

    # Click the Dashboard link (simulate navigation)
    get dashboard_path
    assert_response :success
  end
end
