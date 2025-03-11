class Api::V1::UsersController < Api::V1::BaseController
  # GET /api/v1/profile
  def profile
    render json: current_user
  end
  
  # GET /api/v1/users/:id/adventures
  def adventures
    user = User.find(params[:id])
    @adventures = user.adventures
    render json: @adventures
  end
end
