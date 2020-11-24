class EventsController < ApplicationController
  def index
    @events = Event.All
  end

  def show
    @event = Event.find(params[:id])
  end
end
