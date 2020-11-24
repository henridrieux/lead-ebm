class RecruitmentsController < ApplicationController
  def index
    @recruitments = Recruitment.All
  end

  def show
    @recruitment = Recruitment.find(params[:id])
  end
end
