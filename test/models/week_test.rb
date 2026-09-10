require "test_helper"

class WeekTest < ActiveSupport::TestCase
  setup do
    @household = create_household!
  end

  test "start_date normalized to Monday" do
    week = @household.weeks.create!(start_date: Date.new(2026, 8, 26), people_count: 2) # Wednesday
    assert_equal Date.new(2026, 8, 24), week.start_date
  end

  test "start_date accepts strings" do
    week = @household.weeks.create!(start_date: "2026-08-27", people_count: 2)
    assert_equal Date.new(2026, 8, 24), week.start_date
  end

  test "unique (household, start_date)" do
    @household.weeks.create!(start_date: Date.new(2026, 8, 24), people_count: 2)
    duplicate = @household.weeks.build(start_date: Date.new(2026, 8, 26), people_count: 2)
    assert_not duplicate.valid?
    assert duplicate.errors[:start_date].any?
  end

  test "people_count must be positive" do
    week = @household.weeks.build(start_date: Date.new(2026, 8, 24), people_count: 0)
    assert_not week.valid?
    assert week.errors[:people_count].any?
  end

  test "build_days! creates 7 consecutive dates" do
    week = create_week!(@household, Date.new(2026, 8, 24))
    dates = week.days.order(:date).map(&:date)
    assert_equal (0..6).map { |i| Date.new(2026, 8, 24) + i.days }, dates
  end

  test "second build_days! is a no-op" do
    week = create_week!(@household)
    assert_no_difference "Day.count" do
      week.build_days!
    end
  end

  test "copy_from maps Monday to Monday and does not overwrite filled slots" do
    source = create_week!(@household, Date.new(2026, 8, 17))
    birria = create_recipe!(name: "Birria de res")
    pozole = create_recipe!(name: "Pozole")
    assign_slot!(source, 0, "comida", birria)
    assign_slot!(source, 1, "cena", pozole)

    target = create_week!(@household, Date.new(2026, 8, 24))
    existing_recipe = create_recipe!(name: "Ya asignado")
    assign_slot!(target, 1, "cena", existing_recipe)

    target.copy_from(source)

    monday = target.days.find_by(date: Date.new(2026, 8, 24))
    assert_equal birria.id, monday.menu_for("comida").recipe_id

    tuesday = target.days.find_by(date: Date.new(2026, 8, 25))
    # Filled slot is NOT overwritten by the copy
    assert_equal existing_recipe.id, tuesday.menu_for("cena").recipe_id
    assert_equal 1, tuesday.menu_days.count
  end

  test "clear! removes menu_days only, keeps days and shopping list" do
    week = create_week!(@household)
    recipe = create_recipe!
    assign_slot!(week, 0, "desayuno", recipe)
    assign_slot!(week, 2, "comida", recipe)
    week.build_shopping_list.save!

    week.clear!

    assert_equal 0, week.filled_slot_count
    assert_equal 7, week.days.count
    assert week.reload.shopping_list.present?
  end

  test "label includes Semana del" do
    week = create_week!(@household, Date.new(2026, 8, 24))
    assert_equal "Semana del 24 ago", week.label
  end

  test "previous_start_date and next_start_date are ±7 days" do
    week = create_week!(@household, Date.new(2026, 8, 24))
    assert_equal Date.new(2026, 8, 17), week.previous_start_date
    assert_equal Date.new(2026, 8, 31), week.next_start_date
  end

  test "for_household_and_date find-or-initializes normalized Monday" do
    week = Week.for_household_and_date(@household, Date.new(2026, 8, 26))
    assert week.new_record?
    assert_equal Date.new(2026, 8, 24), week.start_date
  end

  test "filled_slot_count and full?" do
    week = create_week!(@household)
    recipe = create_recipe!
    assign_slot!(week, 0, "comida", recipe)
    assert_equal 1, week.filled_slot_count
    assert_not week.full?
    week.days.order(:date).each do |day|
      Week::MEAL_TYPES.each do |meal_type|
        day.menu_days.create!(meal_type: meal_type, recipe: recipe, servings: 1) unless day.menu_for(meal_type)
      end
    end
    assert week.full?
  end
end
