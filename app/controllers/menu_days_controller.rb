class MenuDaysController < ApplicationController
  before_action :set_week
  before_action :set_day

  def new
    @menu_day = @day.menu_days.build(meal_type: params[:meal_type] || Week::MEAL_TYPES.first)
    @recipes = Recipe.includes(:tags).order(:name)
    render layout: false
  end

  def create
    @menu_day = @day.menu_days.find_or_initialize_by(meal_type: menu_day_params[:meal_type])
    @menu_day.recipe_id = menu_day_params[:recipe_id]
    @menu_day.servings = params.dig(:menu_day, :servings).presence || @week.people_count

    if @menu_day.save
      redirect_to week_path(@week), notice: "Platillo asignado."
    else
      redirect_to week_path(@week), alert: @menu_day.errors.full_messages.to_sentence
    end
  end

  def update
    @menu_day = @day.menu_days.find(params[:id])
    if @menu_day.update(menu_day_params)
      redirect_to week_path(@week), notice: "Platillo actualizado."
    else
      redirect_to week_path(@week), alert: @menu_day.errors.full_messages.to_sentence
    end
  end

  def destroy
    @menu_day = @day.menu_days.find(params[:id])
    @menu_day.destroy
    redirect_to week_path(@week), notice: "Platillo removido del slot."
  end

  private

  def set_week
    @week = current_household.weeks.find(params[:week_id])
  end

  def set_day
    @day = @week.days.find(params[:day_id])
  end

  def menu_day_params
    params.require(:menu_day).permit(:meal_type, :recipe_id, :servings)
  end
end
