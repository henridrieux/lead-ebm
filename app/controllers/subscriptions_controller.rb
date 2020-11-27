class SubscriptionsController < ApplicationController
  def index
    @subscriptions = policy_scope(Subscription).order(created_at: :desc)
  end

  def show
    @subscription = Subscription.find(params[:id])
    authorize @subscription
  end

  # def new
  #   @subscription = Subscription.new
  #   @events_category = Events_category.find(params[:events_category_id])
  #   @subscription.events_category = @events_category
  #   authorize @subscription
  # end

  def create
    @subscription = Subscription.new
    @event_category = EventCategory.find(params[:event_category_id])
    @subscription.event_category = @event_category
    @subscription.user = current_user
    @subscription.status = "Activé"
    # @subscription.start_date = Date.now()
    authorize @subscription
    if @subscription.save
      redirect_to category_path(@event_category.category)
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
