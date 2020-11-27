class EventCategoriesController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?

  def index
    @event_categories = policy_scope(EventCategory.all)
  end

  def show
    @event_category = EventCategory.find(params[:id])
    @recruitments = Recruitment.where(category: @event_category.category)
    @recruitments = @recruitments.where(publication_date: "#{Date.today}")
    # query = @event_category.event.query
    query = ""
    query_params_1 = Date.today - 900
    @companies = Company.where(category: @event_category.category)
    @companies = @companies.where(query, limit_date: "#{query_params_1}") if @companies
  end
end
