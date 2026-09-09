class UsersController < ApplicationController
  before_action :set_household
  before_action :set_user, only: [:edit, :update, :destroy]

  # GET /users/new
  def new
    @user = @household.users.build
  end

  # GET /users/:id/edit
  def edit
  end

  # POST /users
  def create
    @user = @household.users.build(user_params)

    if @user.save
      redirect_to settings_path, notice: "Miembro agregado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      redirect_to settings_path, notice: "Miembro actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    redirect_to settings_path, notice: "Miembro eliminado."
  end

  private

  def set_household
    @household = Household.first || Household.create!(name: "Mi hogar")
  end

  def set_user
    @user = @household.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :role)
  end
end