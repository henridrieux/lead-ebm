class CategoriesController < ApplicationController
  def index
    @categories = policy_scope(Category).order(created_at: :desc)
  end

  def show
    @category = Category.find(params[:id])
  end
end
