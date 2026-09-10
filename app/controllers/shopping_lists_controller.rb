class ShoppingListsController < ApplicationController
  def index
    @lists = current_household.weeks.joins(:shopping_list).includes(shopping_list: :list_items).order(start_date: :desc)
  end

  def show
    @list = ShoppingList.includes(list_items: :ingredient).find(params[:id])
  end

  def create
    @week = current_household.weeks.find(params[:week_id] || params[:id])
    @list = @week.shopping_list || @week.build_shopping_list
    @list.regenerate!
    redirect_to @list, notice: "Lista de compras generada."
  end

  def toggle_item
    @list = ShoppingList.find(params[:id])
    @item = @list.list_items.find(params[:item_id])
    @item.update!(purchased: !@item.purchased)
    redirect_to @list
  end
end
