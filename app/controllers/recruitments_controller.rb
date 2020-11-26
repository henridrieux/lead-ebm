class RecruitmentsController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?

  def index
    @recruitments = policy_scope(Recruitment.all)
  end

  def show
    @recruitment = policy_scope(Recruitment.find(params[:id]))
  end
end
