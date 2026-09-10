ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Shared factories — explicit create! per spec §14 (fixtures optional, prefer
# explicit creation so tests document the contract).
module TestFactories
  def create_household!(name = "Mi hogar")
    Household.create!(name: name)
  end

  def create_user!(household, email: "persona@hogar.test", role: "planificador")
    household.users.create!(email: email, role: role)
  end

  def create_week!(household, start_date = Date.current, people_count: 2)
    week = Week.new(household: household, start_date: start_date, people_count: people_count)
    week.save!
    week.build_days!
    week
  end

  def create_recipe!(name: "Receta de prueba", base_servings: 4, prep_time_min: 30,
                     description: nil, instructions: nil, ingredients: {}, tags: [])
    recipe = Recipe.new(
      name: name,
      base_servings: base_servings,
      prep_time_min: prep_time_min,
      description: description || "Descripción de #{name}",
      instructions: instructions || "Paso 1\nPaso 2"
    )
    ingredients.each do |ingredient_name, attrs|
      ingredient = Ingredient.find_or_create_named!(ingredient_name, unit: attrs[:unit], category: attrs[:category])
      recipe.recipe_ingredients.build(ingredient: ingredient, quantity: attrs[:quantity], unit: attrs[:unit])
    end
    recipe.save!
    tags.each { |tag_name| recipe.tags << Tag.find_or_create_by!(name: tag_name) }
    recipe
  end

  def assign_slot!(week, day_offset, meal_type, recipe, servings: nil)
    day = week.days.find_by(date: week.start_date + day_offset.days)
    day.menu_days.create!(meal_type: meal_type, recipe: recipe, servings: servings || week.people_count)
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    include TestFactories
  end
end
