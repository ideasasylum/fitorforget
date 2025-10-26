require "test_helper"

class ProgramsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @program = @user.programs.create!(title: "Test Program", description: "Test description")
    @other_program = @other_user.programs.create!(title: "Other Program")
  end

  test "should redirect to signin when not authenticated" do
    get programs_path
    assert_redirected_to signin_path
    assert_equal "Please sign in to continue", flash[:alert]
  end

  test "index requires authentication" do
    get programs_path
    assert_redirected_to signin_path
  end

  test "new requires authentication" do
    get new_program_path
    assert_redirected_to signin_path
  end

  test "create requires authentication" do
    post programs_path, params: { program: { title: "Test" } }
    assert_redirected_to signin_path
  end

  test "show requires authentication" do
    get program_path(@program)
    assert_redirected_to signin_path
  end

  test "edit requires authentication" do
    get edit_program_path(@program)
    assert_redirected_to signin_path
  end

  test "update requires authentication" do
    patch program_path(@program), params: { program: { title: "Updated" } }
    assert_redirected_to signin_path
  end

  test "destroy requires authentication" do
    delete program_path(@program)
    assert_redirected_to signin_path
  end
end
