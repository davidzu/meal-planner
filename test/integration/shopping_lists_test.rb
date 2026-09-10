require "test_helper"

class ShoppingListsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @household = create_household!
    @week = create_week!(@household, Date.new(2026, 8, 24), people_count: 4)
    @recipe = create_recipe!(name: "Birria", base_servings: 4, ingredients: {
      "Carne de res para guisar" => {quantity: 2, unit: "kg", category: "carniceria"},
      "Cebolla" => {quantity: 2, unit: "pieza", category: "verduleria"}
    })
    assign_slot!(@week, 0, "comida", @recipe)
  end

  test "POST generate redirects to show with items" do
    post shopping_list_week_path(@week)
    assert_redirected_to shopping_list_path(@week.shopping_list)

    get shopping_list_path(@week.shopping_list)
    assert_response :ok
    assert_select ".list-item", 2
    assert_select ".list-group__title", /Carnicería/
    assert_select ".list-group__title", /Verdulería/
  end

  test "generate is idempotent — regenerating rebuilds same list" do
    post shopping_list_week_path(@week)
    list = @week.shopping_list
    assert_difference "ListItem.count", 0 do
      post shopping_list_week_path(@week)
    end
    assert_equal list.id, @week.reload.shopping_list.id
  end

  test "PATCH toggle_item flips purchased" do
    list = @week.build_shopping_list.regenerate!
    item = list.list_items.first

    patch toggle_item_shopping_list_path(list), params: {item_id: item.id}
    assert_redirected_to shopping_list_path(list)
    assert item.reload.purchased?

    patch toggle_item_shopping_list_path(list), params: {item_id: item.id}
    assert_not item.reload.purchased?
  end

  test "GET index lists weeks that have a list" do
    get shopping_lists_path
    assert_response :ok
    assert_select ".empty-state" # no lists yet

    @week.build_shopping_list.regenerate!
    get shopping_lists_path
    assert_response :ok
    assert_select "table tr", /Semana del/
  end

  test "index does not 500 when some weeks have no list" do
    create_week!(@household, Date.new(2026, 8, 31))
    get shopping_lists_path
    assert_response :ok
  end
end
