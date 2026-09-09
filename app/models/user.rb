class User < ApplicationRecord
  belongs_to :household

  ROLES = %w[planificador cocinero].freeze

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :role, inclusion: {in: ROLES}, allow_nil: true

  has_many :recipes, foreign_key: :author_id, dependent: :nullify, inverse_of: :author
end