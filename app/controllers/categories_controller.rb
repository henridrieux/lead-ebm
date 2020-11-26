class CategoriesController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?

  def index
    if params[:query].present?
      sql_query = " \
        categories.name @@ :query \
        OR categories.description @@ :query \
      "
      @categories = policy_scope(Category.where(sql_query, query: "%#{params[:query]}%"))
    else
      @categories = policy_scope(Category.all).order(created_at: :desc)
    end
  end

  def show
    @category = Category.find(params[:id])
    # @event_categories = EventCategory.all
    # @events = Event.all
  end
end
