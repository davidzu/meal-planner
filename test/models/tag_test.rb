require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "name presence and uniqueness" do
    Tag.create!(name: "guisado")
    duplicate = Tag.new(name: "guisado")
    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "label is readable Spanish" do
    assert_equal "Desayuno rápido", Tag.new(name: "desayuno_rapido").label
    assert_equal "Guisado", Tag.new(name: "guisado").label
    assert_equal "Oaxaqueño", Tag.new(name: "oaxaqueño").label
  end

  test "recipes through recipe_tags" do
    tag = Tag.create!(name: "cena")
    recipe = create_recipe!(name: "Tacos")
    recipe.tags << tag
    assert_includes tag.recipes, recipe
  end
end
