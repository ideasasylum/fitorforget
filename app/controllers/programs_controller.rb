class ProgramsController < ApplicationController
  before_action :require_authentication
  before_action :set_program, only: [:show, :edit, :update, :destroy]

  def index
    @programs = current_user.programs.order(created_at: :desc)
  end

  def show
  end

  def new
    @program = current_user.programs.build
  end

  def create
    @program = current_user.programs.build(program_params)

    if @program.save
      redirect_to programs_path, notice: "Program created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @program.update(program_params)
      redirect_to program_path(@program), notice: "Program updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @program.destroy
    redirect_to programs_path, notice: "Program deleted successfully"
  end

  private

  def set_program
    @program = current_user.programs.find_by!(uuid: params[:id])
  end

  def program_params
    params.require(:program).permit(:title, :description)
  end
end
