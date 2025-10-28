require "application_system_test_case"

class WorkoutCompletionTest < ApplicationSystemTestCase
  # Helper to click button with retry for Turbo Stream DOM updates
  def click_button_with_retry(text, max_attempts: 3)
    attempts = 0
    begin
      attempts += 1
      find_button(text, wait: 5).click
    rescue Playwright::Error => e
      if e.message.include?("not attached to the DOM") && attempts < max_attempts
        sleep 0.1
        retry
      else
        raise
      end
    end
  end
  test "test_completing_workout_and_viewing_dashboard_on_desktop" do
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

    # Start workout via UI
    visit program_path(@program)
    click_link "Start Workout"
    click_button "Begin Workout"

    # Verify first exercise displayed
    assert_text "Exercise 1"
    assert_text "Set 1 of 3"

    # Complete first exercise (Set 1 of Exercise 1)
    click_button "Mark Complete"

    # Assert second exercise appears (Set 2 of Exercise 1)
    assert_text "Exercise 1"
    assert_text "Set 2 of 3"

    # Assert progress updates (2 of 9)
    assert_text "Exercise 2 of 9"

    # Complete second exercise (Set 2 of Exercise 1)
    click_button "Mark Complete"

    # Assert third exercise appears (Set 3 of Exercise 1)
    assert_text "Exercise 1"
    assert_text "Set 3 of 3"

    # Assert progress updates (3 of 9)
    assert_text "Exercise 3 of 9"

    # Complete remaining 7 exercises to finish workout
    7.times do |i|
      # Use retry helper to handle Turbo Stream DOM updates
      click_button_with_retry("Mark Complete")
    end

    # Assert completion message appears
    assert_text "Workout Complete! 🎉"
    assert_text "You completed 9 of 9 exercises"

    # Visit dashboard
    visit dashboard_path

    # Assert completed workout visible in recent workouts
    assert_text "Recent Workouts"
    assert_text "Test Program"

    # Assert workout shows completed status
    assert_text "9 of 9 exercises complete"

    # Assert completion timestamp visible (uses "Created X ago")
    assert_text "ago"
  end

  test "test_completing_workout_and_viewing_dashboard_on_mobile" do
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

    # Start workout via UI
    visit program_path(@program)
    click_link "Start Workout"
    click_button "Begin Workout"

    # Verify first exercise displayed
    assert_text "Exercise 1"
    assert_text "Set 1 of 3"

    # Complete first exercise (Set 1 of Exercise 1)
    click_button "Mark Complete"

    # Assert second exercise appears (Set 2 of Exercise 1)
    assert_text "Exercise 1"
    assert_text "Set 2 of 3"

    # Assert progress updates (2 of 9)
    assert_text "Exercise 2 of 9"

    # Complete second exercise (Set 2 of Exercise 1)
    click_button "Mark Complete"

    # Assert third exercise appears (Set 3 of Exercise 1)
    assert_text "Exercise 1"
    assert_text "Set 3 of 3"

    # Assert progress updates (3 of 9)
    assert_text "Exercise 3 of 9"

    # Complete remaining 7 exercises to finish workout
    7.times do |i|
      # Use retry helper to handle Turbo Stream DOM updates
      click_button_with_retry("Mark Complete")
    end

    # Assert completion message appears
    assert_text "Workout Complete! 🎉"
    assert_text "You completed 9 of 9 exercises"

    # Visit dashboard
    visit dashboard_path

    # Assert completed workout visible in recent workouts
    assert_text "Recent Workouts"
    assert_text "Test Program"

    # Assert workout shows completed status
    assert_text "9 of 9 exercises complete"

    # Assert completion timestamp visible (uses "Created X ago")
    assert_text "ago"
  end
end
