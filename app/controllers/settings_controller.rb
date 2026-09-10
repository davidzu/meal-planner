class SettingsController < ApplicationController
  def index
    @household = current_household
    @members = current_household.users.order(:email)
  end
end
