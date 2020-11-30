class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def dashboard
    @my_sub = Subscription.includes(:event_category, :category, :event).where(user: current_user)
    @my_sub_cat = @my_sub.map{ |v| v.category }.uniq
    @my_sub_event_cat = @my_sub.map{ |v| v.event_category }.uniq
    @my_sub_event = @my_sub.map{ |v| v.event }.uniq

    # @my_leads_array = []
    # @my_sub_event_cat.each do |event_category|
    #   @my_leads_array << event_category.get_company_leads
    # end
  end

end
