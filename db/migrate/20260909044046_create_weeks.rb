class CreateWeeks < ActiveRecord::Migration[8.1]
  def change
    create_table :weeks do |t|
      t.date :start_date, null: false
      t.integer :people_count, null: false, default: 2
      t.references :household, null: false, foreign_key: true

      t.timestamps
    end
    add_index :weeks, [:household_id, :start_date], unique: true
  end
end
