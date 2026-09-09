class Week < ApplicationRecord
  belongs_to :household
  has_many :days, dependent: :destroy
  has_one :shopping_list, dependent: :destroy

  validates :start_date, presence: true, uniqueness: {scope: :household_id}
  validates :people_count, presence: true, numericality: {only_integer: true, greater_than: 0}

  MEAL_TYPES = %w[desayuno comida cena].freeze

  # Always a Monday. If given a non-Monday date, roll back to the Monday of that week.
  def self.normalize_start_date(date)
    date = Date.parse(date) if date.is_a?(String)
    date.to_date.beginning_of_week(:monday)
  end

  def self.for_household_and_date(household, date)
    find_or_initialize_by(household: household, start_date: normalize_start_date(date))
  end

  def start_date=(value)
    super(value.blank? ? value : self.class.normalize_start_date(value))
  end

  def end_date
    start_date + 6.days
  end

  def label
    "Semana del #{I18n.l(start_date, format: :short)}"
  end

  def build_days!
    return if days.any?

    (0..6).each do |offset|
      days.create!(date: start_date + offset.days)
    end
  end

  def filled_slot_count
    days.joins(:menu_days).count
  end

  def full?
    filled_slot_count >= 21
  end

  def copy_from(other_week)
    other_week.days.includes(:menu_days).each do |source_day|
      # Match by offset within the week (Mon→Mon), not by date.
      target_day = days.find_by(date: start_date + (source_day.date - other_week.start_date).to_i.days)
      next unless target_day

      source_day.menu_days.each do |menu_day|
        target_day.menu_days.find_or_create_by!(meal_type: menu_day.meal_type) do |md|
          md.recipe = menu_day.recipe
          md.servings = menu_day.servings
        end
      end
    end
    self
  end
end