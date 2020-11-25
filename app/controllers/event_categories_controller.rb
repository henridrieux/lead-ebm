class EventCategoriesController < ApplicationController
  def index
    @event_categories = EventCategory.all
  end

  def show
    @event_categories = EventCategory.all
  end
end
