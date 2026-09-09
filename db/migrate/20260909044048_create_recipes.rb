class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :name, null: false
      t.text :description
      t.text :instructions
      t.integer :prep_time_min
      t.integer :base_servings, null: false, default: 4
      t.integer :calories_per_serving
      t.references :author, null: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
