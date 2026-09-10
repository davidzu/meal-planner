require "application_system_test_case"

class SettingsSystemTest < ApplicationSystemTestCase
  setup do
    @household = create_household!
  end

  test "settings shows household and frozen meal types" do
    visit settings_path

    assert_text "Ajustes"
    assert_text "Tipos de comida: Desayuno, Comida, Cena"
    assert_field "Nombre del hogar", with: "Mi hogar"
  end

  test "add a member with role cocinero" do
    visit settings_path
    click_on "Agregar miembro"

    fill_in "Correo", with: "cocinero@hogar.test"
    select "Cocinero", from: "Rol"
    click_on "Agregar"

    assert_text "Miembro agregado."
    assert_text "cocinero@hogar.test"
    assert_text "Cocinero"
  end

  test "rename the household" do
    visit settings_path
    fill_in "Nombre del hogar", with: "Casa de los Martínez"
    click_on "Guardar"

    assert_text "Hogar actualizado."
    assert_field "Nombre del hogar", with: "Casa de los Martínez"
  end
end
