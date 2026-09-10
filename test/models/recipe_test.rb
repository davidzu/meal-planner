require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "name presence" do
    recipe = Recipe.new(base_servings: 4)
    assert_not recipe.valid?
    assert recipe.errors[:name].any?
  end

  test "base_servings must be positive" do
    recipe = Recipe.new(name: "X", base_servings: 0)
    assert_not recipe.valid?
    assert recipe.errors[:base_servings].any?
  end

  test "prep_time_min positive when present" do
    recipe = Recipe.new(name: "X", base_servings: 4, prep_time_min: -5)
    assert_not recipe.valid?
    assert recipe.errors[:prep_time_min].any?
  end

  test "nested attributes create ingredient join rows" do
    ingredient = Ingredient.find_or_create_named!("Cilantro")
    recipe = Recipe.create!(
      name: "Con nested",
      base_servings: 2,
      recipe_ingredients_attributes: [{ingredient_id: ingredient.id, quantity: 1, unit: "pieza"}]
    )
    assert_equal 1, recipe.recipe_ingredients.count
    assert_equal ingredient.id, recipe.recipe_ingredients.first.ingredient_id
  end

  test "nested attributes reject all-blank rows" do
    recipe = Recipe.create!(name: "Sin blanks", base_servings: 2, recipe_ingredients_attributes: [{quantity: "", unit: ""}])
    assert_equal 0, recipe.recipe_ingredients.count
  end

  test "search ILIKE name and description" do
    birria = create_recipe!(name: "Birria de res", description: "Platillo jalisciense")
    create_recipe!(name: "Ensalada", description: "Fresca")
    assert_includes Recipe.search("birria"), birria
    assert_includes Recipe.search("jalisciense"), birria
    assert_empty Recipe.search("inexistente")
  end

  test "by_tag" do
    tag = Tag.create!(name: "guisado")
    guisado = create_recipe!(name: "Guisado", tags: [])
    guisado.tags << tag
    create_recipe!(name: "Otro")
    assert_equal [guisado.id], Recipe.by_tag(tag.id).map(&:id)
  end

  test "by_max_time" do
    fast = create_recipe!(name: "Rápida", prep_time_min: 10)
    create_recipe!(name: "Lenta", prep_time_min: 120)
    assert_includes Recipe.by_max_time(15), fast
    assert_not_includes Recipe.by_max_time(15), Recipe.find_by(name: "Lenta")
  end

  test "destroy recipe with a menu_day fails (restrict_with_error)" do
    household = create_household!
    week = create_week!(household)
    recipe = create_recipe!
    assign_slot!(week, 0, "comida", recipe)

    assert_no_difference "Recipe.count" do
      recipe.destroy
    end
    assert recipe.errors[:base].any? || recipe.errors.any?
    assert Recipe.exists?(recipe.id)
  end

  test "destroy recipe without slots succeeds" do
    recipe = create_recipe!
    recipe.destroy
    assert_not Recipe.exists?(recipe.id)
  end

  test "total_time_label formats minutes and hours" do
    assert_equal "45 min", create_recipe!(name: "A", prep_time_min: 45).total_time_label
    assert_equal "1h 30m", create_recipe!(name: "B", prep_time_min: 90).total_time_label
    assert_equal "—", create_recipe!(name: "C", prep_time_min: nil).total_time_label
  end
end
