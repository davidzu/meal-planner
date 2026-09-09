class ShoppingListsController < ApplicationController
  before_action :set_household

  # GET /shopping_lists — archive of past weeks
  def index
    @lists = @household.weeks.includes(:shopping_list).where.not(shopping_lists: {id: nil}).order(start_date: :desc)
  end

  # GET /shopping_lists/:id
  def show
    @list = ShoppingList.includes(list_items: :ingredient).find(params[:id])
  end

  # POST /weeks/:week_id/shopping_list
  def create
    @week = Week.find(params[:week_id])
    @week.build_days! unless @week.persisted?
    @list = @week.shopping_list || @week.build_shopping_list
    @list.regenerate!
    redirect_to @list, notice: "Lista de compras generada."
  end

  # PATCH /shopping_lists/:id/toggle_item/:item_id
  def toggle_item
    @list = ShoppingList.find(params[:id])
    @item = @list.list_items.find(params[:item_id])
    @item.update!(purchased: !@item.purchased)
    redirect_to @list
  end

  private

  def set_household
    @household = Household.first || Household.create!(name: "Mi hogar")
  end
end