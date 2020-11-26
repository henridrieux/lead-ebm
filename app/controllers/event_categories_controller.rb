class EventCategoriesController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?
  def index
    @event_categories = policy_scope(EventCategory.all)
  end

  def show
    @event_categories = EventCategory.all
    @category = Category.find(params[:id])
  end
end
