class MenuDaysController < ApplicationController
  before_action :set_week
  before_action :set_day, only: [:new, :create, :destroy]

  # GET /weeks/:week_id/days/:day_id/menu_days/new — recipe picker modal
  def new
    @menu_day = @day.menu_days.build(meal_type: params[:meal_type] || Week::MEAL_TYPES.first)
    @recipes = Recipe.includes(:tags).order(:name)
    render layout: false
  end

  # POST /weeks/:week_id/days/:day_id/menu_days
  def create
    @week.build_days! unless @week.persisted?
    @menu_day = @day.menu_days.find_or_initialize_by(meal_type: menu_day_params[:meal_type])
    @menu_day.recipe_id = menu_day_params[:recipe_id]
    @menu_day.servings = menu_day_params[:servings].presence || 1

    if @menu_day.save
      redirect_to week_path(@week), notice: "Platillo asignado."
    else
      redirect_to week_path(@week), alert: @menu_day.errors.full_messages.to_sentence
    end
  end

  # DELETE /weeks/:week_id/days/:day_id/menu_days/:id
  def destroy
    @menu_day = @day.menu_days.find(params[:id])
    @menu_day.destroy
    redirect_to week_path(@week), notice: "Platillo removido del slot."
  end

  private

  def set_week
    @week = Week.find(params[:week_id])
  end

  def set_day
    @day = @week.days.find(params[:day_id])
  end

  def menu_day_params
    params.require(:menu_day).permit(:meal_type, :recipe_id, :servings)
  end
end