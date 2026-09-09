class SettingsController < ApplicationController
  before_action :set_household

  # GET /settings
  def index
    @household = @household
    @members = @household.users.order(:email)
  end

  private

  def set_household
    @household = Household.first || Household.create!(name: "Mi hogar")
  end
end