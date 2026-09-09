class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  def index
    @recipes = Recipe.includes(:tags, :recipe_ingredients)
                     .search(params[:q])
                     .by_tag(params[:tag_id])
                     .by_max_time(params[:max_time])
                     .by_difficulty(params[:difficulty])
                     .order(:name)
    @tags = Tag.order(:name)
  end

  # GET /recipes/search — lightweight JSON for the picker modal
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

  # GET /recipes/:id
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
    @recipe.recipe_ingredients.build
  end

  # GET /recipes/:id/edit
  def edit
  end

  # POST /recipes
  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "Receta creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recipes/:id
  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Receta actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /recipes/:id
  def destroy
    if @recipe.destroy
      redirect_to recipes_path, notice: "Receta eliminada."
    else
      redirect_to recipes_path, alert: @recipe.errors.full_messages.to_sentence
    end
  end

  private

  def set_recipe
    @recipe = Recipe.includes(:recipe_ingredients, :tags).find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, :description, :instructions, :prep_time_min, :base_servings,
      :calories_per_serving, :author_id,
      tag_ids: [],
      recipe_ingredients_attributes: [:id, :ingredient_id, :quantity, :unit, :prep_note, :_destroy]
    )
  end
end