class Api::V1::AiAdventuresController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:search_similar]
  
  # POST /api/v1/ai_adventures/generate
  # Génère une aventure basée sur un prompt utilisateur et l'enregistre en arrière-plan
  def generate
    authorize :ai_adventure, :generate?
    
    prompt = params[:prompt]
    
    if prompt.blank?
      render json: { error: "Le prompt ne peut pas être vide" }, status: :unprocessable_entity
      return
    end
    
    # Lancer le job en arrière-plan
    job = GenerateAdventureJob.perform_later(current_user.id, prompt, params[:callback_url])
    
    # Répondre immédiatement avec l'ID du job
    render json: { 
      message: "Génération d'aventure en cours", 
      job_id: job.job_id,
      status: "processing"
    }, status: :accepted
  end
  
  # GET /api/v1/ai_adventures/search_similar
  # Recherche des aventures similaires basées sur un texte
  def search_similar
    authorize :ai_adventure, :search_similar?
    
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
  
  # GET /api/v1/ai_adventures/status/:job_id
  # Vérifie le statut d'un job de génération d'aventure
  def status
    authorize :ai_adventure, :status?
    
    job_id = params[:job_id]
    
    if job_id.blank?
      render json: { error: "L'ID du job ne peut pas être vide" }, status: :unprocessable_entity
      return
    end
    
    # Vérifier le statut du job dans Solid Queue
    job = SolidQueue::Job.find_by(id: job_id)
    
    if job.nil?
      render json: { error: "Job non trouvé" }, status: :not_found
      return
    end
    
    status = case job.scheduled_at
    when nil
      if job.finished_at.present?
        "completed"
      else
        "processing"
      end
    else
      "scheduled"
    end
    
    render json: { 
      job_id: job_id,
      status: status,
      scheduled_at: job.scheduled_at,
      finished_at: job.finished_at
    }
  end
end
