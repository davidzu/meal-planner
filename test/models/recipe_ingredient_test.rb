require "test_helper"

class RecipeIngredientTest < ActiveSupport::TestCase
  setup do
    @recipe = create_recipe!
    @ingredient = Ingredient.find_or_create_named!("Tomate")
  end

  test "quantity must be positive" do
    ri = @recipe.recipe_ingredients.build(ingredient: @ingredient, quantity: 0, unit: "kg")
    assert_not ri.valid?
    assert ri.errors[:quantity].any?
  end

  test "unit presence" do
    ri = @recipe.recipe_ingredients.build(ingredient: @ingredient, quantity: 1, unit: "")
    assert_not ri.valid?
    assert ri.errors[:unit].any?
  end

  test "unique (recipe, ingredient)" do
    @recipe.recipe_ingredients.create!(ingredient: @ingredient, quantity: 1, unit: "kg")
    duplicate = @recipe.recipe_ingredients.build(ingredient: @ingredient, quantity: 2, unit: "kg")
    assert_not duplicate.valid?
    assert duplicate.errors[:ingredient_id].any?
  end

  test "ingredient_name virtual attribute is accepted" do
    ri = RecipeIngredient.new(ingredient_name: "Algo nuevo", quantity: 1, unit: "pieza")
    assert_equal "Algo nuevo", ri.ingredient_name
  end
end
