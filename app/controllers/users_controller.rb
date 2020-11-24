class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update]

  def edit
  end

  def update
    @user.update(user_params)
    redirect_to "/dashboard"
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :company_name, :photo)
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end
end
