require "test_helper"

class HouseholdTest < ActiveSupport::TestCase
  test "name presence" do
    assert_not Household.new.valid?
    assert Household.new(name: "Casa").valid?
  end

  test "has many users, destroyed with household" do
    household = create_household!
    user = create_user!(household)
    household.destroy
    assert_not User.exists?(user.id)
  end

  test "has many weeks and shopping lists through weeks" do
    household = create_household!
    week = create_week!(household)
    assert_equal [week], household.weeks
    list = week.build_shopping_list
    list.save!
    assert_equal [list], household.shopping_lists
  end
end
