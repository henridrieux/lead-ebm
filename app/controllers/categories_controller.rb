class CategoriesController < ApplicationController
  def index
    @categories = policy_scope(Category).order(created_at: :desc)
    if params[:query].present?
      sql_query = " \
        categories.name @@ :query \
        OR categories.description @@ :query \
      "
      @categories = Category.joins(:category).where(sql_query, query: "%#{params[:query]}%")
    else
      @categories = Category.all
    end
  end

  def show
    @category = Category.find(params[:id])
  end
end
