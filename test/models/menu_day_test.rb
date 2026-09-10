require "test_helper"

class MenuDayTest < ActiveSupport::TestCase
  setup do
    @household = create_household!
    @week = create_week!(@household)
    @monday = @week.days.first
    @recipe = create_recipe!
  end

  test "meal_type inclusion" do
    menu_day = @monday.menu_days.build(meal_type: "merienda", recipe: @recipe, servings: 2)
    assert_not menu_day.valid?
    assert menu_day.errors[:meal_type].any?
  end

  test "unique (day, meal_type) even with different recipes" do
    other_recipe = create_recipe!(name: "Otra receta")
    @monday.menu_days.create!(meal_type: "comida", recipe: @recipe, servings: 2)
    duplicate = @monday.menu_days.build(meal_type: "comida", recipe: other_recipe, servings: 2)
    assert_not duplicate.valid?
    assert duplicate.errors[:meal_type].any?
  end

  test "same recipe allowed in different meal types on same day" do
    @monday.menu_days.create!(meal_type: "comida", recipe: @recipe, servings: 2)
    dinner = @monday.menu_days.build(meal_type: "cena", recipe: @recipe, servings: 2)
    assert dinner.valid?
  end

  test "servings must be positive integer" do
    menu_day = @monday.menu_days.build(meal_type: "comida", recipe: @recipe, servings: 0)
    assert_not menu_day.valid?
    assert menu_day.errors[:servings].any?
  end

  test "scale_factor 4 servings / 8 base = 0.5" do
    big_recipe = create_recipe!(name: "Receta grande", base_servings: 8)
    menu_day = @monday.menu_days.build(meal_type: "comida", recipe: big_recipe, servings: 4)
    assert_equal 0.5, menu_day.scale_factor
  end

  test "recipe required" do
    menu_day = @monday.menu_days.build(meal_type: "comida", servings: 2)
    assert_not menu_day.valid?
  end
end
