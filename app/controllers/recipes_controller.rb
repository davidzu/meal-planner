class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  def index
    @recipes = Recipe.includes(:tags, :recipe_ingredients)
                     .search(params[:q])
                     .by_tag(params[:tag_id])
                     .by_max_time(params[:max_time])
                     .order(:name)
    @tags = Tag.order(:name)
  end

  def search
    @recipes = Recipe.includes(:tags)
                     .search(params[:q])
                     .by_tag(params[:tag_id])
                     .order(:name)
                     .limit(20)
    render json: @recipes.map { |r|
      {
        id: r.id,
        name: r.name,
        prep_time_min: r.prep_time_min,
        base_servings: r.base_servings,
        tags: r.tags.pluck(:name)
      }
    }
  end

  def show
  end

  def new
    @recipe = Recipe.new
    @recipe.recipe_ingredients.build
  end

  def edit
  end

  def create
    @recipe = Recipe.new(processed_recipe_params)
    assign_author(@recipe)

    if @recipe.save
      if return_to_slot?
        assign_to_slot(@recipe)
      else
        redirect_to @recipe, notice: "Receta creada."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(processed_recipe_params)
      redirect_to @recipe, notice: "Receta actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @recipe.destroy
      redirect_to recipes_path, notice: "Receta eliminada."
    else
      redirect_to recipes_path, alert: @recipe.errors.full_messages.to_sentence
    end
  end

  private

  def set_recipe
    @recipe = Recipe.includes(:tags, :author, recipe_ingredients: :ingredient).find(params[:id])
  end

  def assign_author(recipe)
    users = current_household.users
    return if users.none?

    recipe.author = users.find_by(role: "planificador") || users.first
  end

  def return_to_slot?
    params[:return_week_id].present? && params[:return_day_id].present? && params[:return_meal_type].present?
  end

  def assign_to_slot(recipe)
    week = current_household.weeks.find(params[:return_week_id])
    day = week.days.find(params[:return_day_id])
    menu_day = day.menu_days.find_or_initialize_by(meal_type: params[:return_meal_type])
    menu_day.recipe = recipe
    menu_day.servings = week.people_count
    menu_day.save!
    redirect_to week_path(week), notice: "Receta creada y asignada."
  end

  def processed_recipe_params
    permitted = recipe_params
    attrs = permitted[:recipe_ingredients_attributes]
    return permitted if attrs.blank?

    collection = attrs.respond_to?(:each_value) ? attrs.values : attrs
    collection.each do |ri|
      next if ri[:ingredient_id].present?

      name = ri.delete(:ingredient_name).presence || ri.delete(:name).presence
      next if name.blank?

      ingredient = Ingredient.find_or_create_named!(name, unit: ri[:unit])
      ri[:ingredient_id] = ingredient.id
    end

    permitted
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, :description, :instructions, :prep_time_min, :base_servings,
      :calories_per_serving, :author_id,
      tag_ids: [],
      recipe_ingredients_attributes: [:id, :ingredient_id, :ingredient_name, :name, :quantity, :unit, :prep_note, :_destroy]
    )
  end
end
