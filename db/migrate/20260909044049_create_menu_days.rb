class CreateMenuDays < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_days do |t|
      t.string :meal_type, null: false
      t.integer :servings, null: false, default: 1
      t.references :day, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end
    add_index :menu_days, [:day_id, :meal_type], unique: true
  end
end
