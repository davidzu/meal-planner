# Seed data for the meal planner — real recipes the household actually cooks.
# Idempotent: safe to run multiple times.

household = Household.find_or_create_by!(name: "Mi hogar")

planificador = User.find_or_create_by!(email: "planificador@hogar.test") do |u|
  u.household = household
  u.role = "planificador"
end

cocinero = User.find_or_create_by!(email: "cocinero@hogar.test") do |u|
  u.household = household
  u.role = "cocinero"
end

# --- Ingredients (normalized, with canonical base unit) ---
ingredients = {
  "Carne de res para guisar" => {unit: "kg", category: "carniceria"},
  "Pollo entero" => {unit: "kg", category: "carniceria"},
  "Costillas de cerdo" => {unit: "kg", category: "carniceria"},
  "Chile guajillo" => {unit: "pieza", category: "abarrotes"},
  "Chile ancho" => {unit: "pieza", category: "abarrotes"},
  "Cebolla" => {unit: "pieza", category: "verduleria"},
  "Ajo" => {unit: "pieza", category: "verduleria"},
  "Tomate" => {unit: "pieza", category: "verduleria"},
  "Jitomate" => {unit: "pieza", category: "verduleria"},
  "Zanahoria" => {unit: "pieza", category: "verduleria"},
  "Papa" => {unit: "pieza", category: "verduleria"},
  "Calabacita" => {unit: "pieza", category: "verduleria"},
  "Elote" => {unit: "pieza", category: "verduleria"},
  "Frijol negro" => {unit: "kg", category: "abarrotes"},
  "Arroz" => {unit: "kg", category: "abarrotes"},
  "Fideos de sopa" => {unit: "pieza", category: "abarrotes"},
  "Huevo" => {unit: "pieza", category: "abarrotes"},
  "Queso Oaxaca" => {unit: "kg", category: "abarrotes"},
  "Queso fresco" => {unit: "kg", category: "abarrotes"},
  "Crema" => {unit: "pieza", category: "abarrotes"},
  "Aguacate" => {unit: "pieza", category: "verduleria"},
  "Limón" => {unit: "pieza", category: "verduleria"},
  "Cilantro" => {unit: "pieza", category: "verduleria"},
  "Tortillas de maíz" => {unit: "kg", category: "abarrotes"},
  "Tortillas de harina" => {unit: "pieza", category: "abarrotes"},
  "Salsa verde" => {unit: "pieza", category: "abarrotes"},
  "Salsa roja" => {unit: "pieza", category: "abarrotes"},
  "Sal" => {unit: "kg", category: "abarrotes"},
  "Pimienta" => {unit: "pieza", category: "abarrotes"},
  "Comino" => {unit: "pieza", category: "abarrotes"},
  "Orégano" => {unit: "pieza", category: "abarrotes"},
  "Aceite vegetal" => {unit: "litro", category: "abarrotes"},
  "Vinagre blanco" => {unit: "litro", category: "abarrotes"},
  "Azúcar" => {unit: "kg", category: "abarrotes"},
  "Canela" => {unit: "pieza", category: "abarrotes"},
  "Avena" => {unit: "kg", category: "abarrotes"},
  "Plátano" => {unit: "pieza", category: "verduleria"},
  "Manzana" => {unit: "pieza", category: "verduleria"},
  "Mango" => {unit: "pieza", category: "verduleria"},
  "Leche" => {unit: "litro", category: "abarrotes"},
  "Yogurt natural" => {unit: "pieza", category: "abarrotes"},
  "Miel" => {unit: "pieza", category: "abarrotes"}
}

ingredient_records = {}
ingredients.each do |name, attrs|
  ingredient_records[name] = Ingredient.find_or_create_by!(name: name) do |i|
    i.base_unit = attrs[:unit]
    i.category = attrs[:category]
  end
end

# --- Tags ---
tags = {}
%w[cena desayuno comida desayuno_rapido oaxaqueño guisado sopa vegetariano pollo res cerdo postre].each do |name|
  tags[name] = Tag.find_or_create_by!(name: name)
end

# --- Recipes ---
def seed_recipe(household, author, name, description, instructions, prep_time_min, base_servings, calories, tag_names, ingredient_specs)
  recipe = Recipe.find_or_create_by!(name: name) do |r|
    r.description = description
    r.instructions = instructions
    r.prep_time_min = prep_time_min
    r.base_servings = base_servings
    r.calories_per_serving = calories
    r.author = author
  end

  tag_names.each do |tag_name|
    recipe.tags << Tag.find_by!(name: tag_name) unless recipe.tags.exists?(name: tag_name)
  end

  ingredient_specs.each do |ingredient_name, quantity, unit, prep_note|
    ingredient = Ingredient.find_by!(name: ingredient_name)
    unless recipe.recipe_ingredients.exists?(ingredient: ingredient)
      recipe.recipe_ingredients.create!(
        ingredient: ingredient,
        quantity: quantity,
        unit: unit,
        prep_note: prep_note
      )
    end
  end

  recipe
end

birria = seed_recipe(
  household, cocinero,
  "Birria de res",
  "Guiso tatemado de chiles, perfecto para tacos los domingos.",
  "1. Remoja los chiles en agua caliente 20 min.\n2. Licúa los chiles con ajo, comino y sal.\n3. Dora la carne en aceite, agrega la salsa y agua.\n4. Cocina a fuego lento 2.5 horas hasta que la carne se deshaga.\n5. Sirve con cebolla, cilantro, limón y tortillas.",
  45, 8, 480,
  ["cena", "guisado", "res", "oaxaqueño"],
  [
    ["Carne de res para guisar", 2, "kg", "en trozos grandes"],
    ["Chile guajillo", 6, "pieza", "desvenados"],
    ["Chile ancho", 3, "pieza", "desvenados"],
    ["Ajo", 4, "pieza", nil],
    ["Cebolla", 1, "pieza", nil],
    ["Comino", 1, "pieza", "al gusto"],
    ["Sal", 0.05, "kg", "al gusto"],
    ["Tortillas de maíz", 1, "kg", nil],
    ["Cilantro", 1, "pieza", "picado"],
    ["Limón", 4, "pieza", "en gajos"]
  ]
)

pollo_guisado = seed_recipe(
  household, cocinero,
  "Pollo guisado en salsa verde",
  "Pollo en salsa verde con papas — clásico de entre semana.",
  "1. Hierve el pollo con sal 30 min, reserva el caldo.\n2. Licúa tomate verde, cilantro y chile.\n3. Sofríe la salsa, agrega pollo deshebrado y papas.\n4. Cocina 15 min más hasta espesar.",
  30, 6, 420,
  ["comida", "guisado", "pollo"],
  [
    ["Pollo entero", 1.5, "kg", nil],
    ["Tomate", 6, "pieza", "verde"],
    ["Cilantro", 1, "pieza", nil],
    ["Papa", 4, "pieza", "en cubos"],
    ["Cebolla", 1, "pieza", nil],
    ["Aceite vegetal", 0.05, "litro", nil],
    ["Sal", 0.05, "kg", "al gusto"]
  ]
)

sopa_fideos = seed_recipe(
  household, planificador,
  "Sopa de fideos",
  "Sopa de fideos con caldo de tomate — la entrada que nunca falla.",
  "1. Dora los fideos en aceite hasta que estén dorados.\n2. Licúa jitomate con ajo y cuela.\n3. Agrega el puré a los fideos, luego el caldo.\n4. Cocina 10 min y ajusta de sal.",
  15, 4, 250,
  ["comida", "sopa"],
  [
    ["Fideos de sopa", 1, "pieza", "paquete"],
    ["Jitomate", 4, "pieza", nil],
    ["Ajo", 2, "pieza", nil],
    ["Aceite vegetal", 0.03, "litro", nil],
    ["Sal", 0.03, "kg", "al gusto"]
  ]
)

frijoles = seed_recipe(
  household, cocinero,
  "Frijoles de olla",
  "Frijoles negros de olla con epazote — base de la semana.",
  "1. Remoja los frijoles la noche anterior.\n2. Cocina en olla de presión 45 min con cebolla, ajo y sal.\n3. Deja reposar y sirve con crema y queso fresco.",
  10, 8, 180,
  ["comida", "guisado", "vegetariano"],
  [
    ["Frijol negro", 1, "kg", "remojados"],
    ["Cebolla", 1, "pieza", "en cuartos"],
    ["Ajo", 3, "pieza", nil],
    ["Sal", 0.05, "kg", "al gusto"],
    ["Queso fresco", 0.3, "kg", "desmoronado"],
    ["Crema", 1, "pieza", "al servir"]
  ]
)

arroz = seed_recipe(
  household, planificador,
  "Arroz rojo",
  "Arroz rojo estilo mexicano, esponjoso y dorado.",
  "1. Dora el arroz en aceite hasta que esté doradito.\n2. Licúa jitomate, ajo y caldo.\n3. Agrega al arroz con zanahoria y chícharo.\n4. Tapa y cocina a fuego bajo 18 min sin destapar.",
  20, 6, 220,
  ["comida", "guisado", "vegetariano"],
  [
    ["Arroz", 0.5, "kg", nil],
    ["Jitomate", 3, "pieza", nil],
    ["Ajo", 2, "pieza", nil],
    ["Zanahoria", 1, "pieza", "en cubos"],
    ["Aceite vegetal", 0.05, "litro", nil],
    ["Sal", 0.03, "kg", "al gusto"]
  ]
)

huevos_rancheros = seed_recipe(
  household, planificador,
  "Huevos rancheros",
  "Huevos estrellados sobre tortilla con salsa roja — desayuno completo.",
  "1. Fríe las tortillas ligeramente.\n2. Estrella los huevos en el aceite.\n3. Cubre con salsa roja caliente.\n4. Sirve con frijoles refritos al lado.",
  15, 2, 350,
  ["desayuno", "desayuno_rapido"],
  [
    ["Huevo", 4, "pieza", nil],
    ["Tortillas de maíz", 0.25, "kg", nil],
    ["Salsa roja", 1, "pieza", "frasco"],
    ["Frijol negro", 0.2, "kg", "refritos"],
    ["Aceite vegetal", 0.05, "litro", nil]
  ]
)

avena = seed_recipe(
  household, planificador,
  "Avena con plátano",
  "Avena caliente con plátano, canela y miel.",
  "1. Hierve la avena con leche y agua 5 min.\n2. Agrega plátano en rodajas y canela.\n3. Endulza con miel al servir.",
  10, 2, 280,
  ["desayuno", "desayuno_rapido", "vegetariano"],
  [
    ["Avena", 0.15, "kg", nil],
    ["Leche", 0.5, "litro", nil],
    ["Plátano", 2, "pieza", "en rodajas"],
    ["Canela", 1, "pieza", "al gusto"],
    ["Miel", 0.05, "kg", "al gusto"]
  ]
)

quesadillas = seed_recipe(
  household, planificador,
  "Quesadillas de hongo",
  "Quesadillas con hongos y queso Oaxaca — cena rápida.",
  "1. Saltea los hongos con cebolla y sal.\n2. Rellena las tortillas con hongos y queso.\n3. Dora en el comal hasta que el queso derrita.\n4. Sirve con salsa verde.",
  15, 4, 380,
  ["cena", "desayuno_rapido", "vegetariano"],
  [
    ["Tortillas de harina", 8, "pieza", nil],
    ["Queso Oaxaca", 0.4, "kg", "en tiras"],
    ["Cebolla", 1, "pieza", "en juliana"],
    ["Salsa verde", 1, "pieza", "al servir"],
    ["Aceite vegetal", 0.03, "litro", nil]
  ]
)

costillas = seed_recipe(
  household, cocinero,
  "Costillas en salsa de chile guajillo",
  "Costillas de cerdo guisadas en salsa de guajillo con papas.",
  "1. Hierve las costillas 20 min y escurre.\n2. Licúa guajillo con ajo y orégano.\n3. Sofríe las costillas, agrega la salsa y papas.\n4. Cocina 30 min hasta que todo esté suave.",
  40, 6, 520,
  ["cena", "guisado", "cerdo"],
  [
    ["Costillas de cerdo", 1.5, "kg", nil],
    ["Chile guajillo", 5, "pieza", "desvenados"],
    ["Ajo", 3, "pieza", nil],
    ["Orégano", 1, "pieza", "al gusto"],
    ["Papa", 4, "pieza", "en cubos"],
    ["Sal", 0.05, "kg", "al gusto"]
  ]
)

calabacitas = seed_recipe(
  household, planificador,
  "Calabacitas con elote",
  "Guiso ligero de calabacita y elote con crema.",
  "1. Sofríe cebolla y ajo.\n2. Agrega calabacita y granos de elote.\n3. Cocina 15 min, agrega crema y queso.\n4. Rectifica sal y sirve.",
  20, 4, 240,
  ["comida", "vegetariano"],
  [
    ["Calabacita", 4, "pieza", "en rodajas"],
    ["Elote", 2, "pieza", "desgranado"],
    ["Cebolla", 1, "pieza", nil],
    ["Ajo", 2, "pieza", nil],
    ["Crema", 1, "pieza", nil],
    ["Queso fresco", 0.2, "kg", nil]
  ]
)

def destroy_review_recipe!(recipe)
  MenuDay.where(recipe_id: recipe.id).delete_all
  recipe.destroy!
end

Recipe.where("name LIKE ? OR name LIKE ? OR name LIKE ?", "Review Mix%", "Review Nested%", "% UI").find_each do |recipe|
  destroy_review_recipe!(recipe)
end

Recipe.group(:name).having("COUNT(*) > 1").pluck(:name).each do |name|
  Recipe.where(name: name).order(:id).offset(1).find_each do |recipe|
    destroy_review_recipe!(recipe)
  end
end

Week.for_household_and_date(household, Date.current).tap do |week|
  week.people_count ||= 2
  week.save!
  week.build_days!
end

puts "Seeded: #{Recipe.count} recetas, #{Ingredient.count} ingredientes, #{Tag.count} etiquetas, #{User.count} usuarios, #{Household.count} hogar"