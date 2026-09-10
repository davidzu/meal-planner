class FixListItemsUniqueness < ActiveRecord::Migration[8.1]
  def change
    remove_index :list_items, name: "index_list_items_on_shopping_list_id_and_ingredient_id"
    add_index :list_items,
              [:shopping_list_id, :ingredient_id, :unit],
              unique: true,
              name: "index_list_items_on_list_ingredient_and_unit"
  end
end
