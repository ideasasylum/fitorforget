class CreateCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :external_id, null: false
      t.text :public_key, null: false
      t.integer :sign_count, default: 0, null: false
      t.string :nickname

      t.timestamps
    end

    add_index :credentials, :external_id, unique: true
  end
end
