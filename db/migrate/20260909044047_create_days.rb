class CreateDays < ActiveRecord::Migration[8.1]
  def change
    create_table :days do |t|
      t.date :date, null: false
      t.references :week, null: false, foreign_key: true

      t.timestamps
    end
    add_index :days, [:week_id, :date], unique: true
  end
end
