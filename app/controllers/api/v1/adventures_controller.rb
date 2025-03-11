# @author EMA Team
# @since 0.1.0
#
# Contrôleur pour la gestion des aventures via l'API RESTful.
# Fournit des endpoints pour créer, lire, mettre à jour et supprimer des aventures,
# ainsi que pour rechercher des aventures par titre, description, etc.
#
# Toutes les actions sont soumises aux politiques d'autorisation définies dans AdventurePolicy.
class Api::V1::AdventuresController < Api::V1::BaseController
  before_action :set_adventure, only: [:show, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show, :search]
  
  # Liste toutes les aventures accessibles à l'utilisateur courant
  #
  # @return [JSON] Liste des aventures sérialisées
  # @example
  #   GET /api/v1/adventures
  #   
  #   Réponse:
  #   {
  #     "data": [
  #       {
  #         "id": "1",
  #         "type": "adventure",
  #         "attributes": { ... }
  #       }
  #     ]
  #   }
  def index
    @adventures = policy_scope(Adventure)
    render json: @adventures
  end
  
  # Affiche les détails d'une aventure spécifique
  #
  # @return [JSON] Détails de l'aventure sérialisée
  # @example
  #   GET /api/v1/adventures/1
  #
  #   Réponse:
  #   {
  #     "data": {
  #       "id": "1",
  #       "type": "adventure",
  #       "attributes": { ... }
  #     }
  #   }
  def show
    authorize @adventure
    render json: @adventure
  end
  
  # Crée une nouvelle aventure pour l'utilisateur courant
  #
  # @return [JSON] L'aventure créée ou les erreurs de validation
  # @example
  #   POST /api/v1/adventures
  #   {
  #     "adventure": {
  #       "title": "Randonnée au Lac Bleu",
  #       "description": "Une belle randonnée...",
  #       "location": "Lac Bleu, Pyrénées",
  #       "tags": "randonnée,nature",
  #       "difficulty": "modérée",
  #       "duration": 180,
  #       "distance": 12.5
  #     }
  #   }
  def create
    @adventure = current_user.adventures.build(adventure_params)
    authorize @adventure
    
    if @adventure.save
      render json: @adventure, status: :created
    else
      render json: { errors: @adventure.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # Met à jour une aventure existante
  #
  # @return [JSON] L'aventure mise à jour ou les erreurs de validation
  # @example
  #   PATCH /api/v1/adventures/1
  #   {
  #     "adventure": {
  #       "title": "Nouveau titre",
  #       "description": "Nouvelle description"
  #     }
  #   }
  def update
    authorize @adventure
    
    if @adventure.update(adventure_params)
      render json: @adventure
    else
      render json: { errors: @adventure.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # Supprime une aventure existante
  #
  # @return [void] Retourne un statut 204 No Content en cas de succès
  # @example
  #   DELETE /api/v1/adventures/1
  def destroy
    authorize @adventure
    @adventure.destroy
    head :no_content
  end
  
  # Recherche des aventures par titre, description, lieu ou tags
  #
  # @param query [String] Le terme de recherche
  # @return [JSON] Liste des aventures correspondant aux critères de recherche
  # @example
  #   GET /api/v1/adventures/search?query=montagne
  #
  #   Réponse:
  #   {
  #     "data": [
  #       {
  #         "id": "1",
  #         "type": "adventure",
  #         "attributes": { ... }
  #       }
  #     ]
  #   }
  def search
    if params[:query].present?
      @adventures = Adventure.search_by_title_and_description(params[:query])
    else
      @adventures = Adventure.all
    end
    
    # Filtrer les résultats selon les politiques d'autorisation
    @adventures = policy_scope(@adventures)
    
    render json: @adventures
  end
  
  private
  
  # Récupère l'aventure à partir de l'ID fourni dans les paramètres
  # @return [Adventure] L'aventure trouvée
  # @raise [ActiveRecord::RecordNotFound] Si l'aventure n'existe pas
  def set_adventure
    @adventure = Adventure.find(params[:id])
  end
  
  # Filtre les paramètres autorisés pour la création/mise à jour d'une aventure
  # @return [ActionController::Parameters] Les paramètres filtrés
  def adventure_params
    params.require(:adventure).permit(:title, :description, :location, :tags, :difficulty, :duration, :distance)
  end
end
