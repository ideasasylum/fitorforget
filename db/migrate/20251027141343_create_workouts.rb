class CreateWorkouts < ActiveRecord::Migration[8.1]
  def change
    create_table :workouts do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.references :program, null: false, foreign_key: {on_delete: :cascade}, index: true
      t.text :exercises_data
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
