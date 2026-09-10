class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]

  def new
    @user = current_household.users.build
  end

  def edit
  end

  def create
    @user = current_household.users.build(user_params)

    if @user.save
      redirect_to settings_path, notice: "Miembro agregado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to settings_path, notice: "Miembro actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to settings_path, notice: "Miembro eliminado."
  end

  private

  def set_user
    @user = current_household.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :role)
  end
end
