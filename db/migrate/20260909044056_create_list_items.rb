class CreateListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :list_items do |t|
      t.decimal :quantity, null: false, default: 0, precision: 10, scale: 2
      t.string :unit, null: false
      t.boolean :purchased, null: false, default: false
      t.references :shopping_list, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true

      t.timestamps
    end
    add_index :list_items, [:shopping_list_id, :ingredient_id], unique: true
  end
end
