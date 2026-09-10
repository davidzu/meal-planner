require "test_helper"

class DayTest < ActiveSupport::TestCase
  setup do
    @household = create_household!
    @week = create_week!(@household, Date.new(2026, 8, 24))
  end

  test "name is Spanish for a Monday" do
    monday = @week.days.find_by(date: Date.new(2026, 8, 24))
    assert_equal "Lunes", monday.name
  end

  test "short_name is Spanish abbreviated" do
    monday = @week.days.find_by(date: Date.new(2026, 8, 24))
    assert_equal "Lun", monday.short_name
  end

  test "date unique within week" do
    monday = @week.days.first
    duplicate = @week.days.build(date: monday.date)
    assert_not duplicate.valid?
    assert duplicate.errors[:date].any?
  end

  test "menu_for finds the slot by meal type" do
    monday = @week.days.first
    recipe = create_recipe!
    menu_day = monday.menu_days.create!(meal_type: "comida", recipe: recipe, servings: 2)
    assert_equal menu_day.id, monday.menu_for("comida").id
    assert_nil monday.menu_for("cena")
  end

  test "destroying day destroys its menu_days" do
    monday = @week.days.first
    recipe = create_recipe!
    monday.menu_days.create!(meal_type: "comida", recipe: recipe, servings: 2)
    assert_difference "MenuDay.count", -1 do
      monday.destroy
    end
  end
end
