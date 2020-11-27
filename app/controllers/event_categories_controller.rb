class EventCategoriesController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?

  def index
    @event_categories = policy_scope(EventCategory.all)
  end

  def show
    @event_category = EventCategory.find(params[:id])
    # @category = @event_category.category
    # sql_query = " \
    #   recruitments.publication_date: #{Date.today}  \
    # "
    @recruitments = Recruitment.where(category: @event_category.category)
    @recruitments = @recruitments.where(publication_date: "#{Date.today}")
    @companies = Company.where(category: @event_category.category)
  end
end
