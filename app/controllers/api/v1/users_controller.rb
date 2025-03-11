class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:adventures]
  
  # GET /api/v1/profile
  def profile
    authorize current_user, :profile?
    render json: current_user
  end
  
  # GET /api/v1/users/:id/adventures
  def adventures
    authorize @user, :adventures?
    @adventures = @user.adventures
    @adventures = policy_scope(@adventures)
    render json: @adventures
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
end
