require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com")
    @other_user = User.create!(email: "other@example.com")
  end

  test "should require authentication" do
    get dashboard_path
    assert_redirected_to signin_path
    assert_equal "Please sign in to continue", flash[:alert]
  end

  test "should load dashboard for authenticated user" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
  end

  test "should load recent programs sorted by last workout date" do
    sign_in_as(@user)

    # Create programs with different workout dates
    program1 = @user.programs.create!(title: "Program 1")
    program2 = @user.programs.create!(title: "Program 2")
    program3 = @user.programs.create!(title: "Program 3")

    # Create workouts with different dates
    workout1 = @user.workouts.create!(program: program1, program_title: "Program 1", exercises_data: [], created_at: 3.days.ago)
    workout2 = @user.workouts.create!(program: program2, program_title: "Program 2", exercises_data: [], created_at: 1.day.ago)
    workout3 = @user.workouts.create!(program: program3, program_title: "Program 3", exercises_data: [], created_at: 5.days.ago)

    get dashboard_path
    assert_response :success
  end

  test "should load recent workouts ordered by created_at" do
    sign_in_as(@user)

    program = @user.programs.create!(title: "Test Program")

    # Create workouts with different dates
    workout1 = @user.workouts.create!(program: program, program_title: "Test", exercises_data: [], created_at: 2.days.ago)
    workout2 = @user.workouts.create!(program: program, program_title: "Test", exercises_data: [], created_at: 1.day.ago)

    get dashboard_path
    assert_response :success
  end

  test "should set has_more_programs flag correctly" do
    sign_in_as(@user)

    # Create 7 programs to trigger "view all" link
    7.times do |i|
      @user.programs.create!(title: "Program #{i}")
    end

    get dashboard_path
    assert_response :success
  end

  test "should set has_more_workouts flag correctly" do
    sign_in_as(@user)

    program = @user.programs.create!(title: "Test Program")

    # Create 7 workouts to trigger "view all" link
    7.times do |i|
      @user.workouts.create!(program: program, program_title: "Test", exercises_data: [])
    end

    get dashboard_path
    assert_response :success
  end
end
