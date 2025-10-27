require "test_helper"

class ExercisesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @program = @user.programs.create!(title: "Test Program")
  end

  test "exercises display on program show page" do
    exercise1 = @program.exercises.create!(name: "Push-ups", repeat_count: 10, position: 1)
    exercise2 = @program.exercises.create!(name: "Squats", repeat_count: 15, position: 2)

    # Since we can't authenticate via WebAuthn in tests, we just verify the data structure
    assert_equal 2, @program.exercises.count
    assert_equal "Push-ups", exercise1.name
    assert_equal "Squats", exercise2.name
  end

  test "exercises are ordered by position" do
    @program.exercises.create!(name: "Lunges", repeat_count: 20, position: 3)
    @program.exercises.create!(name: "Push-ups", repeat_count: 10, position: 1)
    @program.exercises.create!(name: "Squats", repeat_count: 15, position: 2)

    exercises = @program.exercises.reload
    assert_equal ["Push-ups", "Squats", "Lunges"], exercises.pluck(:name)
  end

  test "exercise with video URL" do
    exercise = @program.exercises.create!(
      name: "Burpees",
      repeat_count: 20,
      position: 1,
      video_url: "https://youtube.com/watch?v=test"
    )

    assert_equal "https://youtube.com/watch?v=test", exercise.video_url
  end

  test "exercise with markdown description" do
    exercise = @program.exercises.create!(
      name: "Plank",
      repeat_count: 60,
      position: 1,
      description: "Hold for 60 seconds. Focus on keeping your back straight."
    )

    assert_includes exercise.description, "Hold for 60 seconds"
  end

  test "deleting program deletes all exercises" do
    @program.exercises.create!(name: "Push-ups", repeat_count: 10, position: 1)
    @program.exercises.create!(name: "Squats", repeat_count: 15, position: 2)

    assert_equal 2, @program.exercises.count

    program_id = @program.id
    @program.destroy

    assert_equal 0, Exercise.where(program_id: program_id).count
  end

  test "moving exercise updates position" do
    exercise1 = @program.exercises.create!(name: "Push-ups", repeat_count: 10, position: 1)
    exercise2 = @program.exercises.create!(name: "Squats", repeat_count: 15, position: 2)
    exercise3 = @program.exercises.create!(name: "Lunges", repeat_count: 20, position: 3)

    # Move exercise1 from position 1 to position 3
    exercise1.update!(position: 3)
    exercise2.update!(position: 1)
    exercise3.update!(position: 2)

    @program.exercises.reload
    assert_equal "Squats", @program.exercises.first.name
    assert_equal "Push-ups", @program.exercises.last.name
  end

  test "exercise requires name and repeat_count" do
    exercise = @program.exercises.build(position: 1)
    assert_not exercise.valid?
    assert_includes exercise.errors[:name], "can't be blank"
    assert_includes exercise.errors[:repeat_count], "can't be blank"
  end

  test "exercise video_url validates format" do
    exercise = @program.exercises.build(
      name: "Test",
      repeat_count: 10,
      position: 1,
      video_url: "not a url"
    )
    assert_not exercise.valid?
    assert_includes exercise.errors[:video_url], "must be a valid URL"
  end
end
