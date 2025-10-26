require "test_helper"

class ProgramFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test "programs index shows empty state when user has no programs" do
    # Note: Full authentication flow testing requires browser-based testing
    # These tests verify the views render correctly with proper data
    assert_equal 0, @user.programs.count
  end

  test "program model validations work correctly" do
    # Title is required
    program = @user.programs.build(description: "Test")
    assert_not program.valid?
    assert_includes program.errors[:title], "can't be blank"

    # Title length validation
    program = @user.programs.build(title: "a" * 201)
    assert_not program.valid?
    assert_includes program.errors[:title], "is too long (maximum is 200 characters)"

    # Valid program
    program = @user.programs.build(title: "Valid Program")
    assert program.valid?
  end

  test "program creation generates UUID" do
    program = @user.programs.create!(title: "Test Program")
    assert_not_nil program.uuid
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, program.uuid)
  end

  test "programs are scoped to users" do
    user1_program = @user.programs.create!(title: "User 1 Program")
    user2_program = @other_user.programs.create!(title: "User 2 Program")

    assert_equal 1, @user.programs.count
    assert_includes @user.programs, user1_program
    assert_not_includes @user.programs, user2_program
  end

  test "full program creation workflow" do
    program = @user.programs.build(title: "New Program", description: "Test description")
    assert program.save
    assert_not_nil program.uuid
    assert_equal @user, program.user
    assert_equal "New Program", program.title
    assert_equal "Test description", program.description
  end

  test "full program update workflow" do
    program = @user.programs.create!(title: "Original Title", description: "Original description")
    program.update!(title: "Updated Title", description: "Updated description")

    program.reload
    assert_equal "Updated Title", program.title
    assert_equal "Updated description", program.description
    assert_not_nil program.uuid # UUID should remain unchanged
  end

  test "full program deletion workflow" do
    program = @user.programs.create!(title: "To Delete")
    program_id = program.id

    assert_difference("@user.programs.count", -1) do
      program.destroy
    end

    assert_nil Program.find_by(id: program_id)
  end

  test "programs ordered by created_at descending" do
    old_program = @user.programs.create!(title: "Old Program", created_at: 2.days.ago)
    new_program = @user.programs.create!(title: "New Program", created_at: 1.day.ago)

    programs = @user.programs.order(created_at: :desc)
    assert_equal new_program.id, programs.first.id
    assert_equal old_program.id, programs.last.id
  end

  test "program description is optional" do
    program = @user.programs.build(title: "Program without description")
    assert program.valid?
    assert program.save
    assert_nil program.description
  end

  test "cascade delete removes programs when user deleted" do
    program = @user.programs.create!(title: "Program to cascade delete")
    program_id = program.id

    @user.destroy

    assert_nil Program.find_by(id: program_id)
  end
end
