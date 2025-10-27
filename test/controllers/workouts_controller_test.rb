require "test_helper"

class WorkoutsControllerTest < ActionDispatch::IntegrationTest
  # Test 1: Authentication requirement - redirect if not authenticated
  test "should redirect to signin when not authenticated" do
    program = programs(:strength_program)
    post workouts_path, params: { program_id: program.uuid }

    assert_redirected_to signin_path
    assert_equal "Please sign in to continue", flash[:alert]
  end

  # Test 2: Successful workout creation from program
  test "create should snapshot program exercises and redirect to workout" do
    user = users(:john)
    program = programs(:strength_program)
    sign_in_as(user)

    assert_difference "Workout.count", 1 do
      post workouts_path, params: { program_id: program.uuid }
    end

    workout = Workout.last
    assert_equal user.id, workout.user_id
    assert_equal program.id, workout.program_id
    assert_equal program.title, workout.program_title
    assert_not_nil workout.exercises_data
    assert_redirected_to workout_path(workout)
  end

  # Test 3: Show action displays current exercise
  test "show should display current exercise for in-progress workout" do
    user = users(:john)
    program = programs(:strength_program)
    workout = Workout.new(user: user, program: program)
    workout.initialize_from_program(program)
    workout.save!

    sign_in_as(user)

    get workout_path(workout)
    assert_response :success
    # Check that the exercise name is in the response body
    assert_match workout.current_exercise["name"], response.body
  end

  # Test 4: Update action marks exercise complete and redirects
  test "mark_complete should update exercise and redirect" do
    user = users(:john)
    program = programs(:strength_program)
    workout = Workout.new(user: user, program: program)
    workout.initialize_from_program(program)
    workout.save!

    sign_in_as(user)

    exercise_id = workout.exercises_data[0]["id"]

    patch mark_complete_workout_path(workout), params: { exercise_id: exercise_id }

    assert_redirected_to workout_path(workout)
    workout.reload
    assert workout.exercises_data[0]["completed"]
  end

  # Test 5: Authorization - users can only access own workouts
  test "should not allow access to other users workouts" do
    user1 = users(:john)
    user2 = users(:jane)
    program = programs(:strength_program)
    workout = Workout.new(user: user1, program: program)
    workout.initialize_from_program(program)
    workout.save!

    sign_in_as(user2)

    # Should raise ActiveRecord::RecordNotFound because set_workout uses current_user.workouts.find
    get workout_path(workout)
    # If no exception was raised, the test should fail
    assert_response :not_found
  end

  # Task Group 3.1: Tests for auto-duplication on workout start
  test "starting workout from non-owned program duplicates it silently" do
    user = users(:jane)
    other_users_program = programs(:strength_program)  # owned by john
    sign_in_as(user)

    assert_difference("Program.count", 1) do
      assert_difference("Workout.count", 1) do
        post workouts_path, params: { program_id: other_users_program.uuid }
      end
    end

    workout = Workout.last
    duplicated_program = Program.last

    # Workout should be associated with duplicated copy, not original
    assert_equal duplicated_program.id, workout.program_id
    assert_not_equal other_users_program.id, workout.program_id

    # Duplicated program should belong to current user
    assert_equal user.id, duplicated_program.user_id
  end

  test "automatic duplication does not show flash message" do
    user = users(:jane)
    other_users_program = programs(:strength_program)  # owned by john
    sign_in_as(user)

    post workouts_path, params: { program_id: other_users_program.uuid }

    follow_redirect!
    # Should only show the workout started message, not duplication message
    assert_equal "Workout started successfully", flash[:notice]
  end

  test "starting workout from owned program uses original without duplication" do
    user = users(:john)
    owned_program = programs(:strength_program)  # owned by john
    sign_in_as(user)

    assert_no_difference("Program.count") do
      assert_difference("Workout.count", 1) do
        post workouts_path, params: { program_id: owned_program.uuid }
      end
    end

    workout = Workout.last
    # Workout should use original program
    assert_equal owned_program.id, workout.program_id
  end

  test "new action duplicates non-owned program before displaying form" do
    user = users(:jane)
    other_users_program = programs(:strength_program)  # owned by john
    sign_in_as(user)

    initial_program_count = Program.count

    get new_workout_path(program_id: other_users_program.uuid)

    assert_response :success
    # A new program should have been created
    assert_equal initial_program_count + 1, Program.count

    # The newest program should belong to the current user
    newest_program = Program.last
    assert_equal user.id, newest_program.user_id
    assert_not_equal other_users_program.id, newest_program.id
  end

  test "new action uses owned program without duplication" do
    user = users(:john)
    owned_program = programs(:strength_program)  # owned by john
    sign_in_as(user)

    assert_no_difference("Program.count") do
      get new_workout_path(program_id: owned_program.uuid)
    end

    assert_response :success
  end
end
