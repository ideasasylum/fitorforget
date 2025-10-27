class CreatePrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :programs do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.string :title, null: false
      t.text :description
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :programs, :uuid, unique: true
  end
end
