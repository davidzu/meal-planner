require "test_helper"

class WeeksIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @household = create_household!
  end

  test "GET / returns 200 and creates week with 7 days" do
    assert_difference "Week.count", 1 do
      assert_difference "Day.count", 7 do
        get "/"
      end
    end
    assert_response :ok
    assert_select "h1.display", /Semana del/
    assert_select ".week-grid .day-column", 7
  end

  test "GET /weeks/:id shows that week, not today" do
    past = create_week!(@household, Date.new(2026, 1, 5))
    get week_path(past)
    assert_response :ok
    assert_select "h1.display", "Semana del 05 ene"
  end

  test "GET /?date= finds-or-creates that week" do
    get root_path(date: Date.new(2026, 9, 14))
    assert_response :ok
    assert_select "h1.display", "Semana del 14 sep"
  end

  test "POST copy copies slots from source week" do
    source = create_week!(@household, Date.new(2026, 8, 17))
    target = create_week!(@household, Date.new(2026, 8, 24))
    recipe = create_recipe!(name: "Birria de res")
    assign_slot!(source, 0, "comida", recipe)

    post copy_week_path(target), params: {source_week_id: source.id}
    assert_redirected_to week_path(target)

    monday = target.days.find_by(date: Date.new(2026, 8, 24))
    assert_equal recipe.id, monday.menu_for("comida").recipe_id
  end

  test "GET copy is no route" do
    week = create_week!(@household)
    get "#{week_path(week)}/copy"
    assert_response :not_found
  end

  test "POST clear empties the week" do
    week = create_week!(@household)
    recipe = create_recipe!
    assign_slot!(week, 0, "comida", recipe)
    assign_slot!(week, 3, "cena", recipe)

    post clear_week_path(week)
    assert_redirected_to week_path(week)
    assert_equal 0, week.reload.filled_slot_count
    assert_equal 7, week.days.count
  end

  test "PATCH people_count persists" do
    week = create_week!(@household)
    patch week_path(week), params: {week: {people_count: 6}}
    assert_redirected_to week_path(week)
    assert_equal 6, week.reload.people_count
  end

  test "no authentication required" do
    get "/"
    assert_response :ok
    get settings_path
    assert_response :ok
  end
end
