class EventCategoriesController < ApplicationController
  def index
    @events_categories = Events_category.All
  end

  def show
    @events_category = Events_category.find(params[:id])
  end
end
