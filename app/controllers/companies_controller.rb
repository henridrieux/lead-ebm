class CompaniesController < ApplicationController
  after_action :verify_authorized, except: [:show, :index], unless: :skip_pundit?

  def index
    @companies = policy_scope(Company.all)
  end

  def show
    @company = Company.find(params[:id])
  end
end
