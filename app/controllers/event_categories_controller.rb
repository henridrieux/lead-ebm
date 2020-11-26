class EventCategoriesController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?

  def index
    @event_categories = policy_scope(EventCategory.all)
  end

  def show
    @event_category = EventCategory.find(params[:id])
    @category = @event_category.category
    @recruitments = Recruitment.where(category: @category)
  end
end
