require "application_system_test_case"

class WorkoutStartTest < ApplicationSystemTestCase
  test "test_starting_workout_from_program_on_desktop" do
    # Create user and sign in
    user = User.create!(email: "test#{Time.current.to_i}@example.com", webauthn_id: SecureRandom.hex(16))
    sign_in_as(user)

    # Create program with 3 exercises
    @program = Program.create!(title: "Test Program", user: user)
    3.times do |i|
      @program.exercises.create!(
        name: "Exercise #{i + 1}",
        repeat_count: 3,
        description: "Description #{i + 1}",
        position: i + 1
      )
    end

    # Set viewport to desktop size
    page.current_window.resize_to(1280, 720)

    # Visit program show page
    visit program_path(@program)

    # Click "Start Workout" button to go to preview page
    click_link "Start Workout"

    # Assert on preview page
    assert_text "Preview Workout"
    assert_text "9 exercises in this workout"

    # Click "Begin Workout" button to actually start
    click_button "Begin Workout"

    # Assert navigated to workout show page
    assert_text "Exercise 1 of 9"

    # Assert first exercise displayed
    assert_text @program.exercises.first.name

    # Assert progress indicator visible (e.g., "1 of 9" since each exercise has 3 repeats)
    assert_text "Exercise 1 of 9"

    # Assert exercise description displayed
    assert_text "Description 1"

    # Assert repeat count displayed (Set 1 of 3)
    assert_text "Set 1 of 3"

    # Assert navigation controls present (Mark Complete button)
    assert_button "Mark Complete"
    assert_button "Skip"
  end

  test "test_starting_workout_from_program_on_mobile" do
    # Create user and sign in
    user = User.create!(email: "test#{Time.current.to_i}@example.com", webauthn_id: SecureRandom.hex(16))
    sign_in_as(user)

    # Create program with 3 exercises
    @program = Program.create!(title: "Test Program", user: user)
    3.times do |i|
      @program.exercises.create!(
        name: "Exercise #{i + 1}",
        repeat_count: 3,
        description: "Description #{i + 1}",
        position: i + 1
      )
    end

    # Set viewport to mobile size
    page.current_window.resize_to(375, 667)

    # Visit program show page
    visit program_path(@program)

    # Click "Start Workout" button to go to preview page
    click_link "Start Workout"

    # Assert on preview page
    assert_text "Preview Workout"
    assert_text "9 exercises in this workout"

    # Click "Begin Workout" button to actually start
    click_button "Begin Workout"

    # Assert navigated to workout show page
    assert_text "Exercise 1 of 9"

    # Assert first exercise displayed
    assert_text @program.exercises.first.name

    # Assert progress indicator visible (e.g., "1 of 9" since each exercise has 3 repeats)
    assert_text "Exercise 1 of 9"

    # Assert exercise description displayed
    assert_text "Description 1"

    # Assert repeat count displayed (Set 1 of 3)
    assert_text "Set 1 of 3"

    # Assert navigation controls present (Mark Complete button)
    assert_button "Mark Complete"
    assert_button "Skip"
  end
end
