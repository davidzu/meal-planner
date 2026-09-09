class CreateShoppingLists < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_lists do |t|
      t.references :week, index: {unique: true}, null: false, foreign_key: true

      t.timestamps
    end
  end
end
