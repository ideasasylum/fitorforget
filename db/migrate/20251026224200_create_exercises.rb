class CreateExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :exercises do |t|
      t.string :name, null: false
      t.integer :repeat_count, null: false
      t.string :video_url
      t.integer :position, null: false
      t.integer :program_id, null: false

      t.timestamps
    end

    add_foreign_key :exercises, :programs, on_delete: :cascade
    add_index :exercises, :program_id
    add_index :exercises, [:program_id, :position]
  end
end
