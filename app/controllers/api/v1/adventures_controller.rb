class Api::V1::AdventuresController < Api::V1::BaseController
  before_action :set_adventure, only: [:show, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show, :search]
  
  # GET /api/v1/adventures
  def index
    @adventures = Adventure.all
    render json: @adventures
  end
  
  # GET /api/v1/adventures/1
  def show
    render json: @adventure
  end
  
  # POST /api/v1/adventures
  def create
    @adventure = current_user.adventures.build(adventure_params)
    
    if @adventure.save
      render json: @adventure, status: :created
    else
      render json: { errors: @adventure.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /api/v1/adventures/1
  def update
    if @adventure.user_id != current_user.id
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
    
    if @adventure.update(adventure_params)
      render json: @adventure
    else
      render json: { errors: @adventure.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/adventures/1
  def destroy
    if @adventure.user_id != current_user.id
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
    
    @adventure.destroy
    head :no_content
  end
  
  # GET /api/v1/adventures/search
  def search
    if params[:query].present?
      @adventures = Adventure.search_by_title_and_description(params[:query])
    else
      @adventures = Adventure.all
    end
    
    render json: @adventures
  end
  
  private
  
  def set_adventure
    @adventure = Adventure.find(params[:id])
  end
  
  def adventure_params
    params.require(:adventure).permit(:title, :description, :location, :tags, :difficulty, :duration, :distance)
  end
end
