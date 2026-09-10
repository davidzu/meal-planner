class Recipe < ApplicationRecord
  belongs_to :author, class_name: "User", optional: true

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags
  has_many :menu_days, dependent: :restrict_with_error

  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :prep_time_min, numericality: {only_integer: true, greater_than: 0}, allow_nil: true
  validates :base_servings, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :calories_per_serving, numericality: {only_integer: true, greater_than: 0}, allow_nil: true

  scope :search, ->(term) {
    where("name ILIKE ? OR description ILIKE ?", "%#{term}%", "%#{term}%") if term.present?
  }
  scope :by_tag, ->(tag_id) { joins(:recipe_tags).where(recipe_tags: {tag_id: tag_id}) if tag_id.present? }
  scope :by_max_time, ->(minutes) { where("prep_time_min <= ?", minutes) if minutes.present? }

  def total_time_label
    return "—" if prep_time_min.blank?

    if prep_time_min < 60
      "#{prep_time_min} min"
    else
      "#{prep_time_min / 60}h #{prep_time_min % 60}m"
    end
  end

  def tag_names
    tags.pluck(:name).join(", ")
  end
end