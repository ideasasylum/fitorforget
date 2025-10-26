class AddDescriptionToExercises < ActiveRecord::Migration[8.1]
  def change
    add_column :exercises, :description, :text
  end
end
