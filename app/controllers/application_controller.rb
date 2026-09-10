class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes

  helper_method :current_household

  def current_household
    @current_household ||= Household.first || Household.create!(name: "Mi hogar")
  end
end
