class WeeksController < ApplicationController
  before_action :set_household
  before_action :set_week, only: [:update, :copy]

  # GET / — current week planner (default screen)
  def show
    @week = Week.for_household_and_date(@household, params[:date] || Date.today)
    @week.save! unless @week.persisted?
    @week.build_days!
    @previous_week = Week.where(household: @household).where("start_date < ?", @week.start_date).order(start_date: :desc).first
    @next_week = Week.where(household: @household).where("start_date > ?", @week.start_date).order(start_date: :asc).first
  end

  # PATCH/PUT /weeks/:id
  def update
    if @week.update(week_params)
      redirect_to week_path(@week), notice: "Semana actualizada."
    else
      render :show, status: :unprocessable_entity
    end
  end

  # GET /weeks/:id/copy/:source_week_id
  def copy
    source = Week.find(params[:source_week_id])
    @week.build_days! unless @week.persisted?
    @week.copy_from(source)
    redirect_to week_path(@week), notice: "Semana copiada desde #{source.label}."
  end

  private

  def set_household
    @household = Household.first || Household.create!(name: "Mi hogar")
  end

  def set_week
    @week = Week.find(params[:id])
  end

  def week_params
    params.require(:week).permit(:start_date, :people_count)
  end
end