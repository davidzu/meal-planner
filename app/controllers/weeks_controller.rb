class WeeksController < ApplicationController
  before_action :set_week, only: [:update, :copy, :clear]

  def show
    if params[:id].present?
      @week = current_household.weeks.find(params[:id])
    else
      @week = Week.for_household_and_date(current_household, params[:date] || Date.current)
      @week.save! if @week.new_record?
    end
    @week.build_days!
    prepare_week_navigation
  end

  def update
    if @week.update(week_params)
      redirect_to week_path(@week), notice: "Semana actualizada."
    else
      @week.build_days!
      prepare_week_navigation
      render :show, status: :unprocessable_entity
    end
  end

  def copy
    source = current_household.weeks.find(params[:source_week_id])
    @week.build_days!
    @week.copy_from(source)
    redirect_to week_path(@week), notice: "Semana copiada desde #{source.label}."
  end

  def clear
    @week.clear!
    redirect_to week_path(@week), notice: "Semana vaciada."
  end

  private

  def set_week
    @week = current_household.weeks.find(params[:id])
  end

  def prepare_week_navigation
    @previous_start_date = @week.previous_start_date
    @next_start_date = @week.next_start_date
    @previous_week = current_household.weeks.where("start_date < ?", @week.start_date).order(start_date: :desc).first
  end

  def week_params
    params.require(:week).permit(:start_date, :people_count)
  end
end
