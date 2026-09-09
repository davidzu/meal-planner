class ListItem < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :ingredient

  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :unit, presence: true
  validates :ingredient_id, uniqueness: {scope: :shopping_list_id}

  def quantity_label
    q = quantity.to_f
    q == q.to_i ? q.to_i.to_s : q.to_s
  end

  def label
    "#{quantity_label} #{unit} · #{ingredient.name}"
  end
end