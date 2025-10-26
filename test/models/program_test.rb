require "test_helper"

class ProgramTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid with title and user" do
    program = @user.programs.build(title: "Upper Body Strength")
    assert program.valid?
  end

  test "should require title" do
    program = @user.programs.build(description: "Some description")
    assert_not program.valid?
    assert_includes program.errors[:title], "can't be blank"
  end

  test "should require title length maximum 200 characters" do
    program = @user.programs.build(title: "a" * 201)
    assert_not program.valid?
    assert_includes program.errors[:title], "is too long (maximum is 200 characters)"
  end

  test "should require user association" do
    program = Program.new(title: "Test Program")
    assert_not program.valid?
    assert_includes program.errors[:user], "must exist"
  end

  test "should generate UUID on create" do
    program = @user.programs.create(title: "Test Program")
    assert_not_nil program.uuid
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, program.uuid)
  end

  test "should belong to user" do
    program = @user.programs.create(title: "Test Program")
    assert_equal @user, program.user
  end
end
