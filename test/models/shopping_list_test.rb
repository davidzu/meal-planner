require "test_helper"

class ShoppingListTest < ActiveSupport::TestCase
  setup do
    @household = create_household!
    @week = create_week!(@household, Date.new(2026, 8, 24), people_count: 4)
  end

  # §14.5 case 1: one slot, 2 kg carne base 8 servings, slot servings 4 → 1.0 kg
  test "regenerate! scales quantity by servings / base_servings" do
    carne = Ingredient.find_or_create_named!("Carne de res para guisar", unit: "kg", category: "carniceria")
    recipe = create_recipe!(name: "Birria", base_servings: 8, ingredients: {"Carne de res para guisar" => {quantity: 2, unit: "kg"}})
    assign_slot!(@week, 0, "comida", recipe, servings: 4)

    list = @week.build_shopping_list.regenerate!

    assert_equal 1, list.list_items.count
    item = list.list_items.first
    assert_equal carne.id, item.ingredient_id
    assert_equal "kg", item.unit
    assert_equal 1.0, item.quantity.to_f
  end

  # §14.5 case 2: two slots, same ingredient same unit → summed on one row
  test "regenerate! sums same ingredient with same unit" do
    recipe = create_recipe!(name: "Guisado", base_servings: 4, ingredients: {"Tomate" => {quantity: 2, unit: "pieza"}})
    assign_slot!(@week, 0, "comida", recipe)
    assign_slot!(@week, 1, "cena", recipe)

    list = @week.build_shopping_list.regenerate!

    assert_equal 1, list.list_items.count
    assert_equal 4.0, list.list_items.first.quantity.to_f
  end

  # §14.5 case 3: two slots, same ingredient different units → two rows, no exception
  test "regenerate! keeps different units of one ingredient as two rows" do
    Ingredient.find_or_create_named!("Queso fresco", unit: "kg", category: "abarrotes")
    grams = create_recipe!(name: "En grams", base_servings: 4, ingredients: {"Queso fresco" => {quantity: 500, unit: "g"}})
    kilos = create_recipe!(name: "En kilos", base_servings: 4, ingredients: {"Queso fresco" => {quantity: 1, unit: "kg"}})
    assign_slot!(@week, 0, "comida", grams)
    assign_slot!(@week, 1, "cena", kilos)

    list = @week.build_shopping_list.regenerate!

    assert_equal 2, list.list_items.count
    units = list.list_items.map(&:unit).sort
    assert_equal %w[g kg], units
  end

  test "regenerate! resets purchased state and rebuilds" do
    recipe = create_recipe!(name: "Guisado", ingredients: {"Tomate" => {quantity: 2, unit: "pieza"}})
    assign_slot!(@week, 0, "comida", recipe)
    list = @week.build_shopping_list.regenerate!
    list.list_items.first.update!(purchased: true)

    list.regenerate!

    assert_equal 1, list.list_items.count
    assert_not list.list_items.first.purchased?
  end

  test "regenerate! on empty week produces zero items" do
    list = @week.build_shopping_list.regenerate!
    assert_equal 0, list.total_items
  end

  test "total_items / purchased_count / complete?" do
    recipe = create_recipe!(name: "Guisado", ingredients: {"Tomate" => {quantity: 2, unit: "pieza"}, "Cebolla" => {quantity: 1, unit: "pieza"}})
    assign_slot!(@week, 0, "comida", recipe)
    list = @week.build_shopping_list.regenerate!

    assert_equal 2, list.total_items
    assert_equal 0, list.purchased_count
    assert_not list.complete?

    list.list_items.first.update!(purchased: true)
    assert_not list.complete?

    list.list_items.last.update!(purchased: true)
    assert list.complete?
  end

  test "one list per week" do
    @week.create_shopping_list!
    duplicate = ShoppingList.new(week: @week)
    assert_not duplicate.valid?
    assert duplicate.errors[:week_id].any?
  end
end
