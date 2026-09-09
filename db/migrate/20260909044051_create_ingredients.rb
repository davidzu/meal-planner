class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.string :base_unit, null: false, default: "pieza"
      t.decimal :unit_price, precision: 10, scale: 2
      t.string :category, null: false, default: "abarrotes"

      t.timestamps
    end
    add_index :ingredients, :name, unique: true
  end
end
