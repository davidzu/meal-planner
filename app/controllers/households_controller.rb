class HouseholdsController < ApplicationController
  def update
    if current_household.update(household_params)
      redirect_to settings_path, notice: "Hogar actualizado."
    else
      redirect_to settings_path, alert: current_household.errors.full_messages.to_sentence
    end
  end

  private

  def household_params
    params.require(:household).permit(:name)
  end
end
