require "test_helper"

class RecipesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @household = create_household!
    @planificador = create_user!(@household, email: "planificador@hogar.test", role: "planificador")
    @tag = Tag.create!(name: "guisado")
    @birria = create_recipe!(name: "Birria de res", prep_time_min: 120, tags: [])
    @birria.tags << @tag
    create_recipe!(name: "Ensalada fresca", prep_time_min: 10)
  end

  test "index 200 lists recipes" do
    get recipes_path
    assert_response :ok
    assert_select ".recipe-card", 2
  end

  test "search q=Birria filters" do
    get recipes_path, params: {q: "Birria"}
    assert_response :ok
    assert_select ".recipe-card", 1
    assert_select ".recipe-card__title", /Birria/
  end

  test "filter by tag" do
    get recipes_path, params: {tag_id: @tag.id}
    assert_response :ok
    assert_select ".recipe-card", 1
  end

  test "filter by max_time" do
    get recipes_path, params: {max_time: 15}
    assert_response :ok
    assert_select ".recipe-card", 1
    assert_select ".recipe-card__title", /Ensalada/
  end

  test "create with nested ingredients and instructions persists all" do
    assert_difference "Recipe.count", 1 do
      assert_difference "RecipeIngredient.count", 2 do
        post recipes_path, params: {
          recipe: {
            name: "Tacos de prueba",
            instructions: "Paso uno\nPaso dos",
            base_servings: 4,
            prep_time_min: 20,
            recipe_ingredients_attributes: {
              "0" => {ingredient_id: Ingredient.find_or_create_named!("Carne").id, quantity: 1, unit: "kg"},
              "1" => {ingredient_name: "Cilantro nuevo", quantity: 1, unit: "pieza"}
            }
          }
        }
      end
    end
    assert_redirected_to recipe_path(Recipe.last)
    recipe = Recipe.last
    assert_equal "Paso uno\nPaso dos", recipe.instructions
    assert_equal 2, recipe.recipe_ingredients.count
    assert Ingredient.exists?(name: "Cilantro nuevo")
  end

  test "create sets author to first planificador" do
    post recipes_path, params: {recipe: {name: "Con autor", base_servings: 2}}
    assert_equal @planificador.id, Recipe.find_by(name: "Con autor").author_id
  end

  test "update changes fields" do
    patch recipe_path(@birria), params: {recipe: {name: "Birria estilo Jalisco", base_servings: 6}}
    assert_redirected_to recipe_path(@birria)
    assert_equal "Birria estilo Jalisco", @birria.reload.name
    assert_equal 6, @birria.base_servings
  end

  test "destroy blocked when recipe is planned" do
    week = create_week!(@household)
    assign_slot!(week, 0, "comida", @birria)

    assert_no_difference "Recipe.count" do
      delete recipe_path(@birria)
    end
    assert_redirected_to recipes_path
    assert Recipe.exists?(@birria.id)
  end

  test "destroy succeeds when not planned" do
    recipe = Recipe.find_by(name: "Ensalada fresca")
    delete recipe_path(recipe)
    assert_redirected_to recipes_path
    assert_not Recipe.exists?(recipe.id)
  end

  test "create with return params assigns the slot and redirects to the week" do
    week = create_week!(@household, Date.new(2026, 8, 24), people_count: 5)
    day = week.days.first

    assert_difference "MenuDay.count", 1 do
      post recipes_path, params: {
        recipe: {name: "Tacos de canasta", base_servings: 4},
        return_week_id: week.id,
        return_day_id: day.id,
        return_meal_type: "comida"
      }
    end
    assert_redirected_to week_path(week)

    menu_day = day.menu_for("comida")
    assert_equal "Tacos de canasta", menu_day.recipe.name
    assert_equal 5, menu_day.servings
  end

  test "invalid create renders unprocessable entity" do
    post recipes_path, params: {recipe: {name: "", base_servings: 0}}
    assert_response :unprocessable_entity
  end

  test "search endpoint returns JSON" do
    get "/recipes/search", params: {q: "Birria"}
    assert_response :ok
    data = JSON.parse(response.body)
    assert_equal 1, data.size
    assert_equal "Birria de res", data.first["name"]
  end
end
