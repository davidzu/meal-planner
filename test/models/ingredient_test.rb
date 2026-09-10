require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "name presence and uniqueness" do
    Ingredient.create!(name: "Cebolla")
    duplicate = Ingredient.new(name: "Cebolla")
    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "category inclusion" do
    ingredient = Ingredient.new(name: "Raro", category: "ferreteria")
    assert_not ingredient.valid?
    assert ingredient.errors[:category].any?
  end

  test "defaults base_unit pieza and category abarrotes" do
    ingredient = Ingredient.create!(name: "Sal de mesa")
    assert_equal "pieza", ingredient.base_unit
    assert_equal "abarrotes", ingredient.category
  end

  test "find_or_create_named! is idempotent" do
    first = Ingredient.find_or_create_named!("Cilantro")
    second = Ingredient.find_or_create_named!("  Cilantro  ")
    assert_equal first.id, second.id
    assert_equal 1, Ingredient.where(name: "Cilantro").count
  end

  test "find_or_create_named! accepts unit and category" do
    ingredient = Ingredient.find_or_create_named!("Carne molida", unit: "kg", category: "carniceria")
    assert_equal "kg", ingredient.base_unit
    assert_equal "carniceria", ingredient.category
  end

  test "category_label is Spanish" do
    assert_equal "Verdulería", Ingredient.new(category: "verduleria").category_label
    assert_equal "Carnicería", Ingredient.new(category: "carniceria").category_label
  end
end
