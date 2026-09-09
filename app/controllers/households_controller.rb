class HouseholdsController < ApplicationController
  before_action :set_household

  # GET /households/:id
  def show
    redirect_to settings_path
  end

  # GET /households/:id/edit
  def edit
  end

  # PATCH/PUT /households/:id
  def update
    if @household.update(household_params)
      redirect_to settings_path, notice: "Hogar actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_household
    @household = Household.first || Household.create!(name: "Mi hogar")
  end

  def household_params
    params.require(:household).permit(:name)
  end
end