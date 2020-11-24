class SubscriptionsController < ApplicationController
  def index
    @subscriptions = policy_scope(Subscription).order(created_at: :desc)
  end

  def show
    @subscription = Subscription.find(params[:id])
    authorize @subscription
  end

  def new
    @subscription = Subscription.new
    @events_category = Events_category.find(params[:events_category_id])
    @subscription.events_category = @events_category
    authorize @subscription
  end

  def create
    @subscription = Subscription.new
    @events_category = Events_category.find(params[:events_category_id])
    @subscription.events_category = @events_category
    @subscription.user = current_user

    authorize @subscription
    if @subscription.save
      redirect_to "*"
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
