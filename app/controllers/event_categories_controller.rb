class EventCategoriesController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?

  def index
    @event_categories = policy_scope(EventCategory.all)
  end


  def show
    @event_category = EventCategory.find(params[:id])

    @recruitments = Recruitment.where(category: @event_category.category)
    @recruitments = @recruitments.where(publication_date: "#{Date.today}")

    @leads = @event_category.get_company_leads
  end


end
