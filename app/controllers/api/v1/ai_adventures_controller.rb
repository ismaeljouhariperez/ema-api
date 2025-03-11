class Api::V1::AiAdventuresController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:search_similar]
  
  # POST /api/v1/ai_adventures/generate
  # Génère une aventure basée sur un prompt utilisateur et l'enregistre
  def generate
    prompt = params[:prompt]
    
    if prompt.blank?
      render json: { error: "Le prompt ne peut pas être vide" }, status: :unprocessable_entity
      return
    end
    
    # Appel au service ema-ai
    ai_service = EmaAiService.new
    result = ai_service.generate_adventure(prompt)
    
    if result[:error].present?
      render json: { error: result[:error], message: result[:message] }, status: :service_unavailable
      return
    end
    
    # Création d'une nouvelle aventure avec les données générées par l'IA
    @adventure = current_user.adventures.build(
      title: result["title"],
      description: result["description"],
      location: result["location"],
      tags: result["tags"].join(","),
      difficulty: result["difficulty"],
      duration: result["duration"],
      distance: result["distance"]
    )
    
    if @adventure.save
      render json: @adventure, status: :created
    else
      render json: { errors: @adventure.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # GET /api/v1/ai_adventures/search_similar
  # Recherche des aventures similaires basées sur un texte
  def search_similar
    query = params[:query]
    
    if query.blank?
      render json: { error: "La requête de recherche ne peut pas être vide" }, status: :unprocessable_entity
      return
    end
    
    # Appel au service ema-ai pour la recherche
    ai_service = EmaAiService.new
    result = ai_service.search_similar(query)
    
    if result[:error].present?
      render json: { error: result[:error], message: result[:message] }, status: :service_unavailable
      return
    end
    
    render json: result
  end
end
