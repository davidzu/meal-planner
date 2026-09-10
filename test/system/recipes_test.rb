require "application_system_test_case"

class RecipesSystemTest < ApplicationSystemTestCase
  setup do
    @household = create_household!
    create_user!(@household, email: "planificador@hogar.test", role: "planificador")
    @tag = Tag.create!(name: "guisado")
    @birria = create_recipe!(name: "Birria de res", prep_time_min: 120, ingredients: {
      "Carne de res para guisar" => {quantity: 2, unit: "kg", category: "carniceria"},
      "Cebolla" => {quantity: 1, unit: "pieza", category: "verduleria"}
    })
    @birria.tags << @tag
    create_recipe!(name: "Ensalada fresca", prep_time_min: 10)
  end

  test "library lists seeded recipes and filters by search" do
    visit recipes_path

    assert_text "Birria de res"
    assert_text "Ensalada fresca"
    assert_selector ".chip", text: "Guisado"

    fill_in "q", with: "Birria"
    click_on "Filtrar"

    assert_text "Birria de res"
    assert_no_text "Ensalada fresca"
  end

  test "create a recipe through the UI" do
    visit recipes_path
    click_on "Nueva receta"

    fill_in "Nombre", with: "Sopa de fideos"
    fill_in "Instrucciones", with: "Dorar la pasta.\nAgregar caldo."
    fill_in "Tiempo (min)", with: "25"
    fill_in "Rinde (porciones)", with: "4"
    within(".ingredient-fields") do
      select "Cebolla", from: "Ingrediente"
      fill_in "Cant.", with: "1"
      fill_in "Unidad", with: "pieza"
    end
    click_on "Crear receta"

    assert_text "Sopa de fideos"
    assert_text "1 pieza de Cebolla"
    assert_text "Dorar la pasta."
  end

  test "extra ingredient row marked Quitar does not block create" do
    visit new_recipe_path

    fill_in "Nombre", with: "Sopa extra"
    fill_in "Rinde (porciones)", with: "4"
    within(all(".ingredient-fields").first) do
      select "Cebolla", from: "Ingrediente"
      fill_in "Cant.", with: "1"
      fill_in "Unidad", with: "pieza"
    end
    click_on "Agregar ingrediente"
    within(all(".ingredient-fields").last) do
      check "Quitar"
    end
    click_on "Crear receta"

    assert_text "Sopa extra"
    assert_text "1 pieza de Cebolla"
  end

  test "empty extra ingredient row does not block create" do
    visit new_recipe_path

    fill_in "Nombre", with: "Sopa vacia"
    fill_in "Rinde (porciones)", with: "4"
    within(all(".ingredient-fields").first) do
      select "Cebolla", from: "Ingrediente"
      fill_in "Cant.", with: "1"
      fill_in "Unidad", with: "pieza"
    end
    click_on "Agregar ingrediente"
    click_on "Crear receta"

    assert_text "Sopa vacia"
    assert_text "1 pieza de Cebolla"
  end
end
