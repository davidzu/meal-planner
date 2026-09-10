require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @household = create_household!
  end

  test "email presence" do
    user = @household.users.build(email: "", role: "cocinero")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email uniqueness" do
    create_user!(@household, email: "a@hogar.test")
    duplicate = @household.users.build(email: "a@hogar.test", role: "cocinero")
    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "email format" do
    user = @household.users.build(email: "not-an-email", role: "cocinero")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "role inclusion" do
    user = @household.users.build(email: "x@hogar.test", role: "jefe")
    assert_not user.valid?
    assert user.errors[:role].any?
  end

  test "role allow_nil" do
    user = @household.users.build(email: "x@hogar.test", role: nil)
    assert user.valid?
  end

  test "destroying user nullifies recipe author_id" do
    user = create_user!(@household, email: "autor@hogar.test")
    recipe = create_recipe!(name: "Con autor")
    recipe.update!(author: user)
    user.destroy
    assert_nil recipe.reload.author_id
    assert Recipe.exists?(recipe.id)
  end
end
