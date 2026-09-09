class Household < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :weeks, dependent: :destroy
  has_many :recipes, through: :users
  has_many :shopping_lists, through: :weeks

  validates :name, presence: true
end