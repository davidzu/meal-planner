class MenuDay < ApplicationRecord
  belongs_to :day
  belongs_to :recipe

  validates :meal_type, presence: true, inclusion: {in: Week::MEAL_TYPES}
  validates :servings, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :meal_type, uniqueness: {scope: :day_id}

  delegate :name, :prep_time_min, :base_servings, to: :recipe, prefix: true

  # Scale factor applied to ingredient quantities for this slot.
  def scale_factor
    servings.to_f / recipe.base_servings.to_f
  end
end