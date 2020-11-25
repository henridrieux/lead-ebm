class CategoriesController < ApplicationController
  after_action :verify_authorized, except: :show, unless: :skip_pundit?
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
    @event_categories = EventCategory.all
  end
end
