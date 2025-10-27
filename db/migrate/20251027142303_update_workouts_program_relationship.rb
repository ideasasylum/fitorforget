class UpdateWorkoutsProgramRelationship < ActiveRecord::Migration[8.1]
  def change
    # Remove the foreign key constraint with cascade delete
    remove_foreign_key :workouts, :programs

    # Make program_id nullable so workouts persist even if program is deleted
    change_column_null :workouts, :program_id, true

    # Add foreign key without cascade delete (nullify instead)
    add_foreign_key :workouts, :programs, on_delete: :nullify

    # Add program_title to store snapshot of program name
    add_column :workouts, :program_title, :string
  end
end
