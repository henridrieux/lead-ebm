class CompaniesController < ApplicationController
  def index
    @companies = Company.All
  end

  def show
    @company = Company.find(params[:id])
  end
end
