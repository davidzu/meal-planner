require "application_system_test_case"

class WeekPlannerSystemTest < ApplicationSystemTestCase
  setup do
    @household = create_household!
    @week = create_week!(@household, Date.current, people_count: 4)
    @birria = create_recipe!(name: "Birria de res", prep_time_min: 120, base_servings: 8, ingredients: {
      "Carne de res para guisar" => {quantity: 2, unit: "kg", category: "carniceria"},
      "Cebolla" => {quantity: 2, unit: "pieza", category: "verduleria"}
    })
  end

  def monday_comida_slot
    column = find(".day-column", match: :first)
    column.all(".meal-slot")[1]
  end

  test "empty week shows 7 columns x 3 empty slots and the hint" do
    visit root_path

    assert_selector ".week-grid .day-column", count: 7
    assert_text "Empieza por el lunes"
    within(".day-column", match: :first) do
      assert_selector ".meal-slot", count: 3
      assert_text "DESAYUNO"
      assert_text "COMIDA"
      assert_text "CENA"
    end
  end

  test "picker search hides non-matching recipes" do
    create_recipe!(name: "Arroz rojo", prep_time_min: 30)

    visit root_path
    monday_comida_slot.find("a", text: "+").click

    within(".picker") do
      assert_selector ".picker__item", text: "Birria de res"
      assert_selector ".picker__item", text: "Arroz rojo"
      find("input[type=search]").set("Birria")
      assert_selector ".picker__item", text: "Birria de res"
      assert_no_selector ".picker__item", text: "Arroz rojo"
    end
  end

  test "assign recipe from the picker (F2)" do
    visit root_path

    monday_comida_slot.find("a", text: "+").click
    assert_selector ".picker"
    within(".picker") do
      assert_text "Birria de res"
      within(".picker__item", text: "Birria de res") do
        click_on "Asignar"
      end
    end

    assert_text "Birria de res"
    assert_text "2h 0m"
    assert_selector ".meal-slot--filled"

    # Reload keeps the assignment
    visit root_path
    assert_text "Birria de res"
  end

  test "generate shopping list from a filled week (F4)" do
    assign_slot!(@week, 0, "comida", @birria)

    visit root_path
    click_on "Generar lista de compras"

    assert_text "Lista de compras"
    assert_text "Carnicería"
    assert_text "Carne de res para guisar"
    assert_text "1 kg" # 2 kg scaled by 4/8
    assert_text "Verdulería"
    assert_text "Cebolla"
  end

  test "create recipe while planning lands it in the originating slot (F5)" do
    visit root_path

    monday_comida_slot.find("a", text: "+").click
    within(".picker") do
      click_on "Nueva receta"
    end

    fill_in "Nombre", with: "Tacos de guisado"
    fill_in "Rinde (porciones)", with: "4"
    fill_in "Instrucciones", with: "Paso 1\nPaso 2"
    within(".ingredient-fields") do
      select "Cebolla", from: "Ingrediente"
      fill_in "Cant.", with: "2"
      fill_in "Unidad", with: "pieza"
    end
    click_on "Crear receta"

    assert_text "Receta creada y asignada"
    assert_text "Tacos de guisado"
    assert_selector ".meal-slot--filled"
  end
end
