require "test_helper"

class MenuDaysIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @household = create_household!
    @week = create_week!(@household, Date.new(2026, 8, 24), people_count: 6)
    @tuesday = @week.days.find_by(date: Date.new(2026, 8, 25))
    @recipe = create_recipe!(name: "Birria de res")
  end

  test "POST assigns recipe to Tuesday comida with default servings = people_count" do
    assert_difference "MenuDay.count", 1 do
      post week_day_menu_days_path(@week, @tuesday),
           params: {menu_day: {meal_type: "comida", recipe_id: @recipe.id}}
    end
    assert_redirected_to week_path(@week)

    menu_day = @tuesday.menu_for("comida")
    assert_equal @recipe.id, menu_day.recipe_id
    assert_equal 6, menu_day.servings
  end

  test "second POST on same slot replaces recipe (find_or_initialize)" do
    other = create_recipe!(name: "Pozole")
    post week_day_menu_days_path(@week, @tuesday),
         params: {menu_day: {meal_type: "comida", recipe_id: @recipe.id}}
    post week_day_menu_days_path(@week, @tuesday),
         params: {menu_day: {meal_type: "comida", recipe_id: other.id}}

    assert_equal 1, @tuesday.menu_days.count
    assert_equal other.id, @tuesday.menu_for("comida").recipe_id
  end

  test "DELETE removes the row" do
    menu_day = assign_slot!(@week, 1, "comida", @recipe)
    assert_difference "MenuDay.count", -1 do
      delete week_day_menu_day_path(@week, @tuesday, menu_day)
    end
    assert_redirected_to week_path(@week)
    assert_nil @tuesday.reload.menu_for("comida")
  end

  test "PATCH servings persists" do
    menu_day = assign_slot!(@week, 1, "comida", @recipe)
    patch week_day_menu_day_path(@week, @tuesday, menu_day), params: {menu_day: {servings: 8}}
    assert_redirected_to week_path(@week)
    assert_equal 8, menu_day.reload.servings
  end

  test "GET new returns 200 picker without layout" do
    get new_week_day_menu_day_path(@week, @tuesday, meal_type: "comida")
    assert_response :ok
    assert_select "turbo-frame#recipe-picker"
    assert_select ".picker__item", Recipe.count
    assert_select "input[type=submit][value=Asignar]"
  end

  test "explicit servings param wins over people_count" do
    post week_day_menu_days_path(@week, @tuesday),
         params: {menu_day: {meal_type: "cena", recipe_id: @recipe.id, servings: 3}}
    assert_equal 3, @tuesday.menu_for("cena").servings
  end
end
