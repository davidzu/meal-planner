require "test_helper"

class SettingsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @household = create_household!
  end

  test "GET /settings returns 200" do
    get settings_path
    assert_response :ok
    assert_select "h1.display", "Ajustes"
    assert_select ".settings-note", /Tipos de comida: Desayuno, Comida, Cena/
  end

  test "POST user adds a member" do
    assert_difference "User.count", 1 do
      post users_path, params: {user: {email: "cocinero@hogar.test", role: "cocinero"}}
    end
    assert_redirected_to settings_path
    assert_equal "cocinero", User.find_by(email: "cocinero@hogar.test").role
  end

  test "POST invalid user renders unprocessable entity" do
    post users_path, params: {user: {email: "nope", role: "cocinero"}}
    assert_response :unprocessable_entity
  end

  test "PATCH household name" do
    patch household_path(@household), params: {household: {name: "Casa nueva"}}
    assert_redirected_to settings_path
    assert_equal "Casa nueva", @household.reload.name
  end

  test "DELETE user removes member" do
    user = create_user!(@household, email: "temporal@hogar.test")
    assert_difference "User.count", -1 do
      delete user_path(user)
    end
    assert_redirected_to settings_path
  end

  test "households#edit is no route" do
    get "/households/#{@household.id}/edit"
    assert_response :not_found
  end

  test "settings lists members ordered by email" do
    create_user!(@household, email: "zeta@hogar.test")
    create_user!(@household, email: "alfa@hogar.test")
    get settings_path
    assert_response :ok
    assert_select ".member-row", 2
  end
end
