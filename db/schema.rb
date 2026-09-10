# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_09_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.bigint "week_id", null: false
    t.index ["week_id", "date"], name: "index_days_on_week_id_and_date", unique: true
    t.index ["week_id"], name: "index_days_on_week_id"
  end

  create_table "households", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "base_unit", default: "pieza", null: false
    t.string "category", default: "abarrotes", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "list_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.boolean "purchased", default: false, null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "shopping_list_id", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_list_items_on_ingredient_id"
    t.index ["shopping_list_id", "ingredient_id", "unit"], name: "index_list_items_on_list_ingredient_and_unit", unique: true
    t.index ["shopping_list_id"], name: "index_list_items_on_shopping_list_id"
  end

  create_table "menu_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "day_id", null: false
    t.string "meal_type", null: false
    t.bigint "recipe_id", null: false
    t.integer "servings", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["day_id", "meal_type"], name: "index_menu_days_on_day_id_and_meal_type", unique: true
    t.index ["day_id"], name: "index_menu_days_on_day_id"
    t.index ["recipe_id"], name: "index_menu_days_on_recipe_id"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ingredient_id", null: false
    t.string "prep_note"
    t.decimal "quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "recipe_id", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id", "ingredient_id"], name: "index_recipe_ingredients_on_recipe_id_and_ingredient_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipe_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "recipe_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "tag_id"], name: "index_recipe_tags_on_recipe_id_and_tag_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_tags_on_recipe_id"
    t.index ["tag_id"], name: "index_recipe_tags_on_tag_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.bigint "author_id"
    t.integer "base_servings", default: 4, null: false
    t.integer "calories_per_serving"
    t.datetime "created_at", null: false
    t.text "description"
    t.text "instructions"
    t.string "name", null: false
    t.integer "prep_time_min"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_recipes_on_author_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "week_id", null: false
    t.index ["week_id"], name: "index_shopping_lists_on_week_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "household_id", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["household_id"], name: "index_users_on_household_id"
  end

  create_table "weeks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.integer "people_count", default: 2, null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "start_date"], name: "index_weeks_on_household_id_and_start_date", unique: true
    t.index ["household_id"], name: "index_weeks_on_household_id"
  end

  add_foreign_key "days", "weeks"
  add_foreign_key "list_items", "ingredients"
  add_foreign_key "list_items", "shopping_lists"
  add_foreign_key "menu_days", "days"
  add_foreign_key "menu_days", "recipes"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipe_tags", "recipes"
  add_foreign_key "recipe_tags", "tags"
  add_foreign_key "recipes", "users", column: "author_id"
  add_foreign_key "shopping_lists", "weeks"
  add_foreign_key "users", "households"
  add_foreign_key "weeks", "households"
end
