class ShoppingList < ApplicationRecord
  belongs_to :week
  has_many :list_items, dependent: :destroy

  validates :week_id, uniqueness: true

  # (Re)generates list items by summing ingredient quantities across every
  # filled menu slot of the week, scaled by servings/base_servings.
  # Merge rule v1: only same-unit ingredients combine; different units of the
  # same ingredient produce separate rows (500 g + 1 kg → two rows).
  def regenerate!
    transaction do
      save! if new_record?
      list_items.destroy_all

      totals = Hash.new { |h, k| h[k] = {quantity: 0.0, unit: nil} }

      week.days.includes(menu_days: {recipe: :recipe_ingredients}).each do |day|
        day.menu_days.each do |menu_day|
          menu_day.recipe.recipe_ingredients.each do |ri|
            scaled = ri.quantity.to_f * menu_day.scale_factor
            key = [ri.ingredient_id, ri.unit]
            totals[key][:quantity] += scaled
            totals[key][:unit] = ri.unit
          end
        end
      end

      totals.each do |(ingredient_id, unit), data|
        list_items.create!(
          ingredient_id: ingredient_id,
          unit: unit,
          quantity: data[:quantity].round(2),
          purchased: false
        )
      end
    end
    self
  end

  def total_items
    list_items.count
  end

  def purchased_count
    list_items.where(purchased: true).count
  end

  def complete?
    total_items.positive? && purchased_count == total_items
  end
end