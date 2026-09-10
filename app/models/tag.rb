class Tag < ApplicationRecord
  LABELS = {
    "cena" => "Cena",
    "desayuno" => "Desayuno",
    "comida" => "Comida",
    "desayuno_rapido" => "Desayuno rápido",
    "oaxaqueño" => "Oaxaqueño",
    "guisado" => "Guisado",
    "sopa" => "Sopa",
    "vegetariano" => "Vegetariano",
    "pollo" => "Pollo",
    "res" => "Res",
    "cerdo" => "Cerdo",
    "postre" => "Postre"
  }.freeze

  has_many :recipe_tags, dependent: :destroy
  has_many :recipes, through: :recipe_tags

  validates :name, presence: true, uniqueness: true

  def label
    LABELS.fetch(name) { name.tr("_", " ").split.map(&:capitalize).join(" ") }
  end
end