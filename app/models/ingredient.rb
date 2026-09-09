class Ingredient < ApplicationRecord
  CATEGORIES = %w[verduleria carniceria abarrotes otros].freeze

  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients
  has_many :list_items, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :base_unit, presence: true
  validates :category, inclusion: {in: CATEGORIES}
  validates :unit_price, numericality: {greater_than_or_equal_to: 0}, allow_nil: true

  def category_label
    {
      "verduleria" => "Verdulería",
      "carniceria" => "Carnicería",
      "abarrotes" => "Abarrotes",
      "otros" => "Otros"
    }.fetch(category, category)
  end
end