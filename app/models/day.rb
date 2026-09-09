class Day < ApplicationRecord
  belongs_to :week
  has_many :menu_days, dependent: :destroy

  validates :date, presence: true, uniqueness: {scope: :week_id}

  def name
    I18n.l(date, format: "%A").capitalize
  end

  def short_name
    I18n.l(date, format: "%a").capitalize
  end

  def menu_for(meal_type)
    menu_days.find_by(meal_type: meal_type)
  end
end