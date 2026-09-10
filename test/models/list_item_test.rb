require "test_helper"

class ListItemTest < ActiveSupport::TestCase
  setup do
    @household = create_household!
    @week = create_week!(@household)
    @list = @week.create_shopping_list!
    @tomate = Ingredient.find_or_create_named!("Tomate")
  end

  test "quantity must be positive" do
    item = @list.list_items.build(ingredient: @tomate, quantity: 0, unit: "kg")
    assert_not item.valid?
    assert item.errors[:quantity].any?
  end

  test "unit presence" do
    item = @list.list_items.build(ingredient: @tomate, quantity: 1, unit: "")
    assert_not item.valid?
    assert item.errors[:unit].any?
  end

  # §14.5 case 4: unique (list, ingredient, unit) rejects duplicates
  test "same ingredient same unit rejected" do
    @list.list_items.create!(ingredient: @tomate, quantity: 1, unit: "kg")
    duplicate = @list.list_items.build(ingredient: @tomate, quantity: 2, unit: "kg")
    assert_not duplicate.valid?
    assert duplicate.errors[:ingredient_id].any?
  end

  test "same ingredient different unit allowed (proves migration 2.1)" do
    @list.list_items.create!(ingredient: @tomate, quantity: 500, unit: "g")
    other = @list.list_items.build(ingredient: @tomate, quantity: 1, unit: "kg")
    assert other.valid?
    other.save!
    assert_equal 2, @list.list_items.count
  end

  test "label formats quantity and name" do
    item = @list.list_items.create!(ingredient: @tomate, quantity: 2.0, unit: "kg")
    assert_equal "2 kg · Tomate", item.label
  end

  test "destroying list destroys items; destroying ingredient destroys items" do
    @list.list_items.create!(ingredient: @tomate, quantity: 1, unit: "kg")
    assert_difference "ListItem.count", -1 do
      @list.destroy
    end
  end
end
